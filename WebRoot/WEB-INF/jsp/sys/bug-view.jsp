<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/taglibs.jsp"%>
<script type="text/javascript">
$(function() {
	
});
</script>
<div>
	<div align="center">
	    <h3>${title}</h3>
	</div>
	<div align="right">
	   [ ${createUser} 发布于 <s:date name="createTime" format="yyyy-MM-dd HH:mm"/>]
	</div>
	<hr>
	<div>${tContent}</div>
</div>