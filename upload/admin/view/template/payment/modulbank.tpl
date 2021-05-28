<?php echo $header; ?><?php echo $column_left; ?>
<div id="content">
  <div class="page-header">
    <div class="container-fluid">
      <div class="pull-right">
        <button type="submit" form="form-cod" data-toggle="tooltip" title="<?php echo $button_save; ?>" class="btn btn-primary"><i class="fa fa-save"></i></button>
        <a href="<?php echo $cancel; ?>" data-toggle="tooltip" title="<?php echo $button_cancel; ?>" class="btn btn-default"><i class="fa fa-reply"></i></a></div>
      <h1><?php echo $heading_title; ?></h1>
      <ul class="breadcrumb">
        <?php foreach ($breadcrumbs as $breadcrumb) { ?>
        <li><a href="<?php echo $breadcrumb['href']; ?>"><?php echo $breadcrumb['text']; ?></a></li>
        <?php } ?>
      </ul>
    </div>
  </div>
  <div class="container-fluid">
    <?php if ($error_warning) { ?>
    <div class="alert alert-danger"><i class="fa fa-exclamation-circle"></i> <?php echo $error_warning; ?>
      <button type="button" class="close" data-dismiss="alert">&times;</button>
    </div>
    <?php } ?>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title"><i class="fa fa-pencil"></i> <?php echo $text_edit; ?></h3>
      </div>
      <div class="panel-body">
        <form action="<?php echo $action; ?>" method="post" enctype="multipart/form-data" id="form-cod" class="form-horizontal">

          <div class="form-group required">
            <label class="col-sm-2 control-label" for="input-paymentname"><?php echo $entry_paymentname; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_paymentname" value="<?php echo $modulbank_paymentname; ?>" placeholder="<?php echo $entry_paymentname; ?>" id="input-paymentname" class="form-control" />
              <?php if($error_paymentname): ?>
              <div class="text-danger"><?php echo $error_paymentname; ?></div>
              <?php endif;?>
            </div>
          </div>
          <div class="form-group required">
            <label class="col-sm-2 control-label" for="input-merchant"><?php echo $entry_merchant; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_merchant" value="<?php echo $modulbank_merchant; ?>" placeholder="<?php echo $entry_merchant; ?>" id="input-merchant" class="form-control" />
              <?php if($error_merchant): ?>
              <div class="text-danger"><?php echo $error_merchant; ?></div>
              <?php endif;?>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-secret_key"><?php echo $entry_secret_key; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_secret_key" value="<?php echo $modulbank_secret_key; ?>" placeholder="<?php echo $entry_secret_key; ?>" id="input-secret_key" class="form-control" />
              <?php if($error_secret_key): ?>
              <div class="text-danger"><?php echo $error_secret_key; ?></div>
              <?php endif;?>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-test_secret_key"><?php echo $entry_test_secret_key; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_test_secret_key" value="<?php echo $modulbank_test_secret_key; ?>" placeholder="<?php echo $entry_test_secret_key; ?>" id="input-test_secret_key" class="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-success_url"><?php echo $entry_success_url; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_success_url" value="<?php echo $modulbank_success_url; ?>" placeholder="<?php echo $entry_success_url; ?>" id="input-success_url" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-fail_url"><?php echo $entry_fail_url; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_fail_url" value="<?php echo $modulbank_fail_url; ?>" placeholder="<?php echo $entry_fail_url; ?>" id="input-fail_url" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-back_url"><?php echo $entry_back_url; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_back_url" value="<?php echo $modulbank_back_url; ?>" placeholder="<?php echo $entry_back_url; ?>" id="input-back_url" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_mode; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_mode" id="input-mode" class="form-control">
                <?php if($modulbank_mode == 'test'): ?>
                <option value="test" selected="selected"><?php echo $text_mode_test; ?></option>
                <?php else: ?>
                <option value="test"><?php echo $text_mode_test; ?></option>
                <?php endif;?>
                <?php if($modulbank_mode == 'prod'): ?>
                <option value="prod" selected="selected"><?php echo $text_mode_prod; ?></option>
                <?php else: ?>
                <option value="prod"><?php echo $text_mode_prod; ?></option>
                <?php endif;?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" ><span data-toggle="tooltip" title="<?php echo $text_pm_checkbox_tooltip; ?>"><?php echo $entry_pm_checkbox; ?></span></label>
            <div class="col-sm-10">
              <div class="checkbox">
                <label>
              <input type="checkbox" name="modulbank_pm_checkbox" value="1" id="modulbank_pm_checkbox" class="form-control" <?php if($modulbank_pm_checkbox):?>checked<?php endif;?> />
              </label>
              </div>
            </div>
          </div>
          <div class="form-group" id="show_payment_methods_block" style="display:none">
            <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_show_payment_methods; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_show_payment_methods[]" id="input-mode" class="form-control" multiple size="2">
                <?php foreach($show_payment_methods_list as $key => $text): ?>
                <?php if(in_array($key,$modulbank_show_payment_methods)): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $text; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $text; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-preauth"><?php echo $entry_preauth; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_preauth" id="input-preauth" class="form-control">
                <?php if($modulbank_preauth == '0'): ?>
                <option value="test" selected="selected"><?php echo $text_preauth_off; ?></option>
                <?php else: ?>
                <option value="0"><?php echo $text_preauth_off; ?></option>
                <?php endif;?>
                <?php if($modulbank_preauth == '1'): ?>
                <option value="1" selected="selected"><?php echo $text_preauth_on; ?></option>
                <?php else: ?>
                <option value="1"><?php echo $text_preauth_on; ?></option>
                <?php endif;?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-confirm-order-status"><?php echo $entry_confirm_order_status_id; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_confirm_order_status_id" id="input-confirm-order-status" class="form-control">
                <?php foreach($order_statuses as $order_status): ?>
                <?php if($order_status['order_status_id'] == $modulbank_confirm_order_status_id): ?>
                <option value="<?php echo $order_status['order_status_id']; ?>" selected="selected"><?php echo $order_status['name']; ?></option>
                <?php else: ?>
                <option value="<?php echo $order_status['order_status_id']; ?>"><?php echo $order_status['name']; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-sno"><?php echo $entry_sno; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_sno" id="input-sno" class="form-control">
                <?php foreach($sno_list as $key => $sno): ?>
                <?php if($key == $modulbank_sno): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $sno; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $sno; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-product-vat"><?php echo $entry_product_vat; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_product_vat" id="input-product-vat" class="form-control">
                <option value="0" ><?php echo $text_vat_0; ?></option>
                <?php foreach($vat_list as $key => $vat): ?>
                <?php if($key == $modulbank_product_vat): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $vat; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $vat; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-delivery-vat"><?php echo $entry_delivery_vat; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_delivery_vat" id="input-delivery-vat" class="form-control">
                <?php foreach($vat_list as $key => $vat): ?>
                <?php if($key == $modulbank_delivery_vat): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $vat; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $vat; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-voucher-vat"><?php echo $entry_voucher_vat; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_voucher_vat" id="input-voucher-vat" class="form-control">
                <?php foreach($vat_list as $key => $vat): ?>
                <?php if($key == $modulbank_voucher_vat): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $vat; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $vat; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-payment-method"><?php echo $entry_payment_method; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_payment_method" id="input-payment-method" class="form-control">
                <?php foreach($payment_method_list as $key => $method): ?>
                <?php if($key == $modulbank_payment_method): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $method; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $method; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-object-method"><?php echo $entry_payment_object; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_payment_object" id="input-object-method" class="form-control">
                <?php foreach($payment_object_list as $key => $object): ?>
                <?php if($key == $modulbank_payment_object): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $object; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $object; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-object-method-delivery"><?php echo $entry_payment_object_delivery; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_payment_object_delivery" id="input-object-method-delivery" class="form-control">
                <?php foreach($payment_object_list as $key => $object): ?>
                <?php if($key == $modulbank_payment_object_delivery): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $object; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $object; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-object-method-voucher"><?php echo $entry_payment_object_voucher; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_payment_object_voucher" id="input-object-method-voucher" class="form-control">
                <?php foreach($payment_object_list as $key => $object): ?>
                <?php if($key == $modulbank_payment_object_voucher): ?>
                <option value="<?php echo $key; ?>" selected="selected"><?php echo $object; ?></option>
                <?php else: ?>
                <option value="<?php echo $key; ?>"><?php echo $object; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-total"><span data-toggle="tooltip" title="<?php echo $help_total; ?>"><?php echo $entry_total; ?></span></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_total" value="<?php echo $modulbank_total; ?>" placeholder="<?php echo $entry_total; ?>" id="input-total" class="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-order-status"><?php echo $entry_order_status; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_order_status_id" id="input-order-status" class="form-control">
                <?php foreach($order_statuses as $order_status): ?>
                <?php if($order_status['order_status_id'] == $modulbank_order_status_id): ?>
                <option value="<?php echo $order_status['order_status_id']; ?>" selected="selected"><?php echo $order_status['name']; ?></option>
                <?php else: ?>
                <option value="<?php echo $order_status['order_status_id']; ?>"><?php echo $order_status['name']; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-order-status"><?php echo $entry_order_refund_status; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_refund_order_status_id" id="input-order-status" class="form-control">
                <?php foreach($order_statuses as $order_status): ?>
                <?php if($order_status['order_status_id'] == $modulbank_refund_order_status_id): ?>
                <option value="<?php echo $order_status['order_status_id']; ?>" selected="selected"><?php echo $order_status['name']; ?></option>
                <?php else: ?>
                <option value="<?php echo $order_status['order_status_id']; ?>"><?php echo $order_status['name']; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-mode"><?php echo $entry_logging; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_logging" id="input-logging" class="form-control">
                <?php if($modulbank_logging == '0'): ?>
                <option value="0" selected="selected"><?php echo $text_logging_off; ?></option>
                <?php else: ?>
                <option value="0"><?php echo $text_logging_off; ?></option>
                <?php endif;?>
                <?php if($modulbank_logging == '1'): ?>
                <option value="1" selected="selected"><?php echo $text_logging_on; ?></option>
                <?php else: ?>
                <option value="1"><?php echo $text_logging_on; ?></option>
                <?php endif;?>
              </select>
              &nbsp;
              <a href="<?php echo $text_log_link; ?>"><?php echo $text_download_logs;?></a>
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-log_size_limit"><?php echo $entry_log_size_limit; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_log_size_limit" value="<?php echo $modulbank_log_size_limit; ?>" placeholder="<?php echo $entry_log_size_limit; ?>" id="input-log_size_limit" class="form-control" />
            </div>
          </div>

          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-geo-zone"><?php echo $entry_geo_zone; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_geo_zone_id" id="input-geo-zone" class="form-control">
                <option value="0"><?php echo $text_all_zones; ?></option>
                <?php foreach($geo_zones as $geo_zone): ?>
                <?php if($geo_zone['geo_zone_id'] == $modulbank_geo_zone_id): ?>
                <option value="<?php echo $geo_zone['geo_zone_id']; ?>" selected="selected"><?php echo $geo_zone['name']; ?></option>
                <?php else: ?>
                <option value="<?php echo $geo_zone['geo_zone_id']; ?>"><?php echo $geo_zone['name']; ?></option>
                <?php endif;?>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-status"><?php echo $entry_status; ?></label>
            <div class="col-sm-10">
              <select name="modulbank_status" id="input-status" class="form-control">
                <?php if($modulbank_status): ?>
                <option value="1" selected="selected"><?php echo $text_enabled; ?></option>
                <option value="0"><?php echo $text_disabled; ?></option>
                <?php else: ?>
                <option value="1"><?php echo $text_enabled; ?></option>
                <option value="0" selected="selected"><?php echo $text_disabled; ?></option>
                <?php endif;?>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="col-sm-2 control-label" for="input-sort-order"><?php echo $entry_sort_order; ?></label>
            <div class="col-sm-10">
              <input type="text" name="modulbank_sort_order" value="<?php echo $modulbank_sort_order; ?>" placeholder="<?php echo $entry_sort_order; ?>" id="input-sort-order" class="form-control" />
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<script>
  jQuery(document).ready(function(){
    var checkbox = jQuery('#modulbank_pm_checkbox');
    var block = jQuery('#show_payment_methods_block');
    if (checkbox.attr('checked')) {
      block.show();
    }
    checkbox.change(function(){
      if (this.checked) {
        block.show();
      } else {
        block.hide();
      }
    });
  });
</script>
<?php echo $footer; ?>