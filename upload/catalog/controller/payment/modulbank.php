<?php

include_once __DIR__ . '/modulbanklib/ModulbankReceipt.php';
include_once __DIR__ . '/modulbanklib/ModulbankHelper.php';

class ControllerPaymentModulbank extends Controller
{
	private function oldversion(){
        return version_compare(VERSION, "2.2.0.0") == -1;
    }

    public function index()
	{

		$this->load->model('checkout/order');
		$this->load->model('payment/modulbank');

		$data = [
			'button_confirm' => $this->language->get('button_confirm'),
			'text_loading' => $this->language->get('text_loading'),
		];

		if($this->oldversion()) {
    		if (file_exists(DIR_TEMPLATE . $this->config->get('config_template') . '/template/payment/modulbank.tpl')) {
                return $this->load->view($this->config->get('config_template') . '/template/payment/modulbank.tpl', $data);
            } else {
                return $this->load->view('default/template/payment/modulbank.tpl', $data);
            }
        } else {
            return $this->load->view('payment/modulbank', $data);
        }
	}

	public function send()
	{

		$this->load->model('checkout/order');
		$this->load->model('payment/modulbank');

		$order_id   = (int) $this->session->data['order_id'];
		$order_info = $this->model_checkout_order->getOrder($order_id);

		$amount  = $this->currency->format($order_info['total'], $order_info['currency_code'], $order_info['currency_value'], false);

		$receiptJson = $this->model_payment_modulbank->getReceiptJson($order_id);

		$sysinfo = [
			'language' => 'PHP ' . phpversion(),
			'plugin'   => $this->model_payment_modulbank->getVersion(),
			'cms'      => 'Opencart ' . VERSION,
		];

		$data = [
			'merchant'        => $this->config->get('modulbank_merchant'),
			'amount'          => $amount,
			'order_id'        => $order_id,
			'testing'         => $this->config->get('modulbank_mode') == 'test' ? 1 : 0,
			'preauth'         => $this->config->get('modulbank_preauth'),
			'description'     => 'Оплата заказа №' . $order_id,
			'success_url'     => $this->config->get('modulbank_success_url'),
			'fail_url'        => $this->config->get('modulbank_fail_url'),
			'cancel_url'      => $this->config->get('modulbank_back_url'),
			'callback_url'    => $this->url->link('payment/modulbank/callback', '', true),
			'client_name'     => $order_info['payment_firstname'],
			'client_email'    => $order_info['email'],
			'receipt_contact' => $order_info['email'],
			'receipt_items'   => $receiptJson,
			'unix_timestamp'  => time(),
			'sysinfo'         => json_encode($sysinfo),
			'salt'            => ModulbankHelper::getSalt(),
		];
		$methods = $this->config->get('modulbank_show_payment_methods');
		if($this->config->get('modulbank_pm_checkbox')) {
			$data['show_payment_methods'] = json_encode($methods);
		}

		$key = $this->model_payment_modulbank->getKey();

		$signature                 = ModulbankHelper::calcSignature($key, $data);
		$data['signature'] = $signature;
		$this->log($data, 'paymentform');

		$orderStatusId = $this->config->get('config_order_status_id');
        $this->model_checkout_order->addOrderHistory($order_id, $orderStatusId, '');

        echo json_encode([
			'error' => false,
			'fields' => $data,
		]);

		exit();
	}

	public function callback()
	{
		$this->load->model('payment/modulbank');
		$this->load->model('checkout/order');
		$post = $_POST;
		$this->log($post, 'callback');
		$key = $this->model_payment_modulbank->getKey();
		$signature = ModulbankHelper::calcSignature($key, $post);

		$order_id = $post['order_id'];

		if (strcmp($post['merchant'],$this->config->get('modulbank_merchant')) !== 0) {
			$this->error('Wrong merchant');
		}

		$order_info = $this->model_checkout_order->getOrder($order_id);

		if (!$order_info) {
			$this->error('Incorrect order id');
		}

		$amount = $this->currency->format($order_info['total'], $order_info['currency_code'], $order_info['currency_value'], false);
		if ($amount != $post['amount']) {
			$this->error('Incorrect payment amount');
		}

		if ($signature === $post['signature']) {
			$this->load->model('checkout/order');
			if (
				(
					$post['state'] === 'COMPLETE' ||
					$post['state'] === 'AUTHORIZED'
				) &&
				$order_info['order_status_id'] != $this->config->get('modulbank_confirm_order_status_id')
			) {
				$this->db->query("REPLACE " . DB_PREFIX . "modulbank (order_id, amount, transaction) VALUES ($order_id,'"
					. $this->db->escape($post['amount']) . "','"
					. $this->db->escape($post['transaction_id']) . "')");
				$this->model_checkout_order->addOrderHistory($order_id, $this->config->get('modulbank_order_status_id'));
			}
		} else {
			$this->error('Wrong signature');
		}
	}

	private function error($msg)
	{
		$this->log($msg, 'error');
		throw new Exception($msg, 1);
	}

	private function log($data, $category)
	{
		$this->load->model('payment/modulbank');
		$this->model_payment_modulbank->log($data, $category);
	}

}
