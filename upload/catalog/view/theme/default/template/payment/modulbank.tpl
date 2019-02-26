<form action="<?php echo $action; ?>" method="post">
  <?php foreach($form as $name => $value):?>
	<input type="hidden" name="<?php echo $name; ?>" value='<?php echo $value; ?>'>
  <?php endforeach;?>
  <div class="buttons">
    <div class="pull-right">
      <input type="submit" value="<?php echo $button_confirm; ?>" class="btn btn-primary" />
    </div>
  </div>
</form>