<?php

class ModulbankReceiptRawItems
{
	private $rawItems = array();

	function addItem($name, $amount, $taxId, $payment_object, $quantity = 1.0)
	{
		if ($amount == 0) {
			return;
		}

		$r = array(
			"quantity"       => $quantity,
			"amount"          => $amount,
			"tax_id"            => $taxId,
			"name"           => $name,
			"payment_object" => $payment_object

		);
		
		$this->rawItems[]=$r;
	}

	function getItems()
	{
		return $this->rawItems;
	}
}

class ModulbankReceipt
{
	private $items         = array();
	private $resultTotal   = 0;
	private $currentSum    = 0;
	private $sno           = '';
	private $paymentMethod = '';



	private function normalize()
	{
		$this->currentSum = round($this->currentSum);
		if ($this->resultTotal != 0 && $this->resultTotal != $this->currentSum) {
			$coefficient = $this->resultTotal / $this->currentSum;
			$realprice   = 0;
			$aloneId     = null;
			foreach ($this->items as $index => &$item) {
				$item['price'] = round($coefficient * $item['price']);
				$realprice += $item['price'] * $item['quantity'] / 1000;
				if ($aloneId === null && $item['quantity'] === 1000) {
					$aloneId = $index;
				}

			}
			unset($item);
			if ($aloneId === null) {
				foreach ($this->items as $index => $item) {
					if ($aloneId === null && $item['quantity'] > 1000) {
						$aloneId = $index;
						break;
					}
				}
			}
			if ($aloneId === null) {
				$aloneId = 0;
			}

			$realprice = round($realprice);

			$diff = $this->resultTotal - $realprice;
			if (abs($diff) >= 0.001) {
				if ($this->items[$aloneId]['quantity'] === 1000) {
					$this->items[$aloneId]['price'] = round($this->items[$aloneId]['price'] + $diff);
				} elseif (
					count($this->items) == 1
					&& abs(round($this->resultTotal / $this->items[$aloneId]['quantity']) - $this->resultTotal / $this->items[$aloneId]['quantity']) < 0.001
				) {
					$this->items[$aloneId]['price'] = round($this->resultTotal / $this->items[$aloneId]['quantity']);
				} elseif ($this->items[$aloneId]['quantity'] > 1000) {
					$tmpItem = $this->items[$aloneId];
					$item    = array(
						"quantity"       => 1000,
						"price"          => round($tmpItem['price'] + $diff),
						"vat"            => $tmpItem['vat'],
						"name"           => $tmpItem['name'],
						"payment_object" => $tmpItem['payment_object'],
						"payment_method" => $tmpItem['payment_method'],
						"sno"            => $tmpItem['sno'],
					);
					$this->items[$aloneId]['quantity'] -= 1000;
					array_splice($this->items, $aloneId + 1, 0, array($item));
				} else {
					$this->items[$aloneId]['price'] = round($this->items[$aloneId]['price'] + $diff / ($this->items[$aloneId]['quantity'] / 1000));

				}
			}
		}
	}

	private function correctDimmensoin()
	{
		foreach ($this->items as &$item) {
			$item['quantity'] = number_format(round($item['quantity'] / 1000, 3), 3, '.', '');
			$item['price']    = number_format(round($item['price'] / 100, 2), 2, '.', '');
		}
	}

	private static function proccessItem($name, $amount, $taxId, $payment_object, $paymentMethod,$sno, $quantity = 1.0)
	{
		if ($amount == 0) {
			return;
		}

		$r = array(
			"quantity"       => round($quantity * 1000),
			"price"          => round($amount * 100),
			"vat"            => $taxId,
			"name"           => $name,
			"payment_object" => $payment_object,
			"payment_method" => $paymentMethod,
			"sno"            => $sno,
		);
		
		return $r;
	}

	public function __construct($RawItemsObject,$sno, $payment_method, $total = 0.0)
	{

		$this->resultTotal   = intval(round($total * 100));
		$this->sno           = $sno;
		$this->paymentMethod = $payment_method;




		$rawitems = $RawItemsObject->getItems();
		
		$this->currentSum = array_sum(array_map( function($item) { return $item["amount"]*100*$item["quantity"]; } , $rawitems  ));

		foreach ($rawitems as $rawitem)
		{
			$this->items[]= self::proccessItem($rawitem["name"],$rawitem["amount"],$rawitem["tax_id"],$rawitem["payment_object"], $payment_method, $sno,$rawitem["quantity"]);
			
		}

		$this->normalize();
		$this->correctDimmensoin();
	}




	public function getItems()
	{

		return $this->items;
	}

	public function getJson()
	{
		return json_encode($this->items, JSON_HEX_APOS | JSON_INVALID_UTF8_IGNORE  |  JSON_UNESCAPED_UNICODE);
	}
}

