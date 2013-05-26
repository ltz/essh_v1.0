<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/taglibs.jsp"%>
<script type="text/javascript">
	$(function() {
		loadSex();
	});
	//性别
	function loadSex(){
		$('#sex').combobox({
	    	url: '${ctx}/js/json/sex.json',
	        width: 120,
	        editable:false,
	        value:'2',
	        valueField: 'value',
	        displayField: 'text'
	    });
	}
</script>
<div>
	<form id="user_form"  method="post" novalidate>
			<input type="hidden" id="user_form_id" name="id"></input> 
			<!-- 用户版本控制字段 version -->
            <input type="hidden" id="version" name="version" ></input>
		    <!-- 	
		    <div class="fitem">
				<label>角色设置:</label>
				<select id="roleIds" name="roleIds" class="easyui-combobox"></select> 
			</div> 
			-->
			<div>
				<label>登录名:</label> 
				<input type="text" id="loginName" name="loginName" maxLength="36"
					class="easyui-validatebox"
					data-options="required:true,missingMessage:'请输入登录名.',validType:['minLength[1]','legalInput']"/> 
				<span style="color: red">*</span>
		</div>
			<div id="password_div">
			<label>密码:</label> 
			<input type="password" id="password"
				name="password" class="easyui-validatebox" maxLength="36"
				data-options="required:true,missingMessage:'请输入密码.',validType:['safepass']"> 
			<span style="color: red">*</span>
		</div>
		<div id="repassword_div">
			<label>确认密码:</label> 
			<input type="password" id="repassword"
				name="repassword" class="easyui-validatebox" required="true"
				missingMessage="请再次填写密码." validType="equalTo['#password']"
				invalidMessage="两次输入密码不匹配.">
			<span style="color: red">*</span>
		</div>
		<div>
				<label>姓名:</label>
				<input name="name" type="text" maxLength="6" class="easyui-validatebox" data-options="validType:['CHS','length[2,6]']" />
			</div>
			<div>
				<label>性别:</label>
				<input id="sex" name="sex" type="text" class="easyui-combobox" />
			</div>
			<div>
				<label>邮箱:</label>
				<input name="email" type="text" class="easyui-validatebox" validType="email" maxLength="255" />
			</div>
			<div>
				<label>地址:</label>
				<input name="address" type="text" class="easyui-validatebox" validType="legalInput" maxLength="255" />
			</div>
			<div>
				<label>电话:</label>
				<input name="tel" type="text" class="easyui-validatebox" validType="phone">
			</div>
			<div>
			    <label>状态:</label>
				<input type="radio" name="status" style="width: 20px;" value="0" /> 启用 
	            <input type="radio" name="status" style="width: 20px;" value="3" /> 停用
			    <span style="color: red">*</span>
			</div>
		</form>
</div>