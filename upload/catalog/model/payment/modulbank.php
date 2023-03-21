<?php
include_once DIR_APPLICATION . 'controller/payment/modulbanklib/ModulbankHelper.php';
include_once DIR_APPLICATION . 'controller/payment/modulbanklib/ModulbankReceipt.php';


class ModelPaymentModulbank extends Model {

	const MAX_NAME_LENGTH=128;
	
	public function getMethod($address, $total) {
		$this->load->language('payment/modulbank');

		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "zone_to_geo_zone WHERE geo_zone_id = '" . (int)$this->config->get('payment_liqpay_geo_zone_id') . "' AND country_id = '" . (int)$address['country_id'] . "' AND (zone_id = '" . (int)$address['zone_id'] . "' OR zone_id = '0')");

		if ($this->config->get('modulbank_total') > 0 && $this->config->get('modulbank_total') > $total) {
			$status = false;
		} elseif (!$this->config->get('modulbank_geo_zone_id')) {
			$status = true;
		} elseif ($query->num_rows) {
			$status = true;
		} else {
			$status = false;
		}


		$method_data = array();

		if ($status) {
			$method_data = array(
				'code'       => 'modulbank',
				'title'      => $this->config->get('modulbank_paymentname'),
        		'title_adv'      => $this->language->get('text_title_adv'),
				'terms'      => '',
				'sort_order' => $this->config->get('modulbank_sort_order')
			);
		}

		return $method_data;
	}

	public function onOrderUpdate($order_id, $order_status_id) {
		if ($order_status_id == $this->config->get('modulbank_refund_order_status_id')) {
			$query = $this->db->query("SELECT * FROM ".DB_PREFIX."modulbank WHERE order_id=".$order_id);
			$key = $this->config->get('modulbank_mode') == 'test'?
						$this->config->get('modulbank_test_secret_key'):
						$this->config->get('modulbank_secret_key');
			if ($query->num_rows) {
				$merchant = $this->config->get('modulbank_merchant');
				$this->log([$merchant,
					$query->row['amount'],
					$query->row['transaction']], 'refund');

				$result = ModulbankHelper::refund(
					$merchant,
					$query->row['amount'],
					$query->row['transaction'],
					$key
				);
				$this->log($result, 'refund_response');
			}
		}

		if (
			$order_status_id == $this->config->get('modulbank_confirm_order_status_id')
			&& $this->config->get('modulbank_preauth')
		) {
			$this->load->model('checkout/order');
			$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "modulbank WHERE order_id=" . $order_id);
			$key   = $this->getKey();
			if ($query->num_rows) {
				$order_info  = $this->model_checkout_order->getOrder($order_id);
				$amount      = $this->currency->format($order_info['total'], $order_info['currency_code'], $order_info['currency_value'], false);
				$receiptJson = $this->getReceiptJson($order_id);
				$data        = [
					'merchant'        => $this->config->get('modulbank_merchant'),
					'amount'          => $amount,
					'transaction'     => $query->row['transaction'],
					'receipt_contact' => $order_info['email'],
					'receipt_items'   => $receiptJson,
					'unix_timestamp'  => time(),
					'salt'            => ModulbankHelper::getSalt(),
				];
				$this->log($data, 'confirm');

				$result = ModulbankHelper::capture($data, $key);
				$this->log($result, 'confirm_response');
			}

		}
	}

	public function getReceiptJson($order_id)
	{
		$this->load->model('checkout/order');

		$order_info = $this->model_checkout_order->getOrder($order_id);

		$sno                     = $this->config->get('modulbank_sno');
		$payment_method          = $this->config->get('modulbank_payment_method');
		$payment_object          = $this->config->get('modulbank_payment_object');
		$payment_object_delivery = $this->config->get('modulbank_payment_object_delivery');
		$payment_object_voucher  = $this->config->get('modulbank_payment_object_voucher');
		$product_vat             = $this->config->get('modulbank_product_vat');
		$delivery_vat            = $this->config->get('modulbank_delivery_vat');
		$voucher_vat             = $this->config->get('modulbank_voucher_vat');

		$amount  = $this->currency->format($order_info['total'], $order_info['currency_code'], $order_info['currency_value'], false);

		$RawItemsObject = new ModulbankReceiptRawItems();


		$query = $this->db->query("
			SELECT op.*, (
				SELECT rate FROM " . DB_PREFIX . "product as p
				LEFT JOIN " . DB_PREFIX . "tax_rule as r on r.tax_class_id=p.tax_class_id
				LEFT JOIN " . DB_PREFIX . "tax_rate as rt on rt.tax_rate_id=r.tax_rate_id and rt.type='P'
				WHERE p.product_id=op.product_id order by rate desc limit 1
			) as rate FROM " . DB_PREFIX . "order_product as op
			WHERE op.order_id = '" . $order_id . "'
			");
		$this->log($order_info, 'order');
		$this->log($query->rows, 'products');

		foreach ($query->rows as $product) {
			if ($product_vat == '0') {
				$rate = intval($product['rate']);
				switch ($rate) {
					case 0:$item_vat = 'vat0';
						break;
					case 10:$item_vat = 'vat10';
						break;
					case 20:$item_vat = 'vat20';
						break;
					default:$item_vat = 'none';
				}
			} else {
				$item_vat = $product_vat;
			}

			$option_data2=array();
					
			$order_option_query = $this->db->query("SELECT * FROM " . DB_PREFIX . "order_option WHERE order_id = '" . (int)$order_id . "' AND order_product_id = '" . (int)$product['order_product_id'] . "'");
			
			foreach ($order_option_query->rows as $option) {
				if ($option['type'] != 'file') {
					$value = $option['value'];
				} else {
					$value = utf8_substr($option['value'], 0, utf8_strrpos($option['value'], '.'));
				}
				
				
				$option_data2[]=$value;
			}

			$options_text=implode(';',$option_data2);

			$name=$product['name'];

			if (!empty($options_text))
				$name.="(".$options_text.")";

			$name = htmlspecialchars_decode($name);
			$name = mb_substr($name,0,self::MAX_NAME_LENGTH);

			$RawItemsObject->addItem($name, $product['price'], $item_vat, $payment_object, $product['quantity']);
		}
		$query = $this->db->query("SELECT * FROM " . DB_PREFIX . "order_voucher WHERE order_id = '" . (int)$order_id . "'");
		foreach ($query->rows as $product) {

			$descr = $product['description'];

			$descr = htmlspecialchars_decode($descr);
			$descr = mb_substr($descr,0,self::MAX_NAME_LENGTH);

			$RawItemsObject->addItem($descr, $product['amount'], $voucher_vat, $payment_object_voucher);
		}
		$query = $this->db->query("SELECT value FROM " . DB_PREFIX . "order_total WHERE order_id = '" . $order_id . "' and code='shipping'");
		if (isset($query->row['value']) && $query->row['value']) {
			$RawItemsObject->addItem('Доставка', $query->row['value'], $delivery_vat, $payment_object_delivery);
		}

		$receipt = new ModulbankReceipt($RawItemsObject,$sno, $payment_method, $amount);

		$r_json=$receipt->getJson();

		if ($r_json===FALSE)
		{
			$this->log(json_last_error()." ".json_last_error_msg(), 'json encode error');
		} else
			$this->log($r_json, 'receipt getJson');
		
		return $r_json;
	}

	public function getTransactionStatus($transaction)
	{
		$merchant = $this->config->get('modulbank_merchant');
		$this->log([$merchant, $transaction], 'getTransactionStatus');

		$key = $this->config->get('modulbank_mode') == 'test'?
						$this->config->get('modulbank_test_secret_key'):
						$this->config->get('modulbank_secret_key');

		$result = ModulbankHelper::getTransactionStatus(
			$merchant,
			$transaction,
			$key
		);
		$this->log($result, 'getTransactionStatus_response');
		return json_decode($result);
	}

	public function getKey()
	{
		if ($this->config->get('modulbank_mode') == 'test') {
			$key = $this->config->get('modulbank_test_secret_key');
		} else {
			$key = $this->config->get('modulbank_secret_key');
		}
		return $key;
	}

	public function log($data, $category)
	{
		if ($this->config->get('modulbank_logging')) {
			$filename   = DIR_LOGS . '/modulbank.log';
			$size_limit = $this->config->get('modulbank_log_size_limit');
			ModulbankHelper::log($filename, $data, $category, $size_limit);
		}
	}

	public function getVersion()
	{
		$query = $this->db->query("SELECT version FROM " . DB_PREFIX . "modification WHERE code = 'modulbank_payment'");
		return $query->row['version'];
	}
}