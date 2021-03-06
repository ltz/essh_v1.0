<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/taglibs.jsp"%>
<%@ include file="/common/meta.jsp"%>
<script type="text/javascript">
var resource_datagrid;//资源列表
var resource_tree;//资源树(左边)
var resource_search_form;//资源搜索表单

var resource_dialog;//资源表单弹出对话框
var resource_form;//资源表单
$(function() {  
	resource_search_form = $('#resource_search_form').form();
	var selectedNode = null;//存放被选中的节点对象 临时变量
	resource_tree = $("#resource_tree").tree({
        url : "${ctx}/base/resource!tree.action",
        onClick:function(node){
        	search();
        },
        onBeforeSelect:function(node){
        	var selected = $(this).tree('getSelected');
        	if(selected){
        		if(selected.id == node.id){
        			$(".tree-node-selected", $(this).tree()).removeClass("tree-node-selected");//移除样式
        			selectedNode = null;
        			return false;
        		}
        	} 
        	selectedNode = node;
        	return true;
        },
        onLoadSuccess:function(node, data){
       		if(selectedNode !=null){
       			selectedNode = $(this).tree('find', selectedNode.id);
       			if(selectedNode !=null){//刷新树后 如果临时变量中存在被选中的节点 则重新将该节点置为被选状态
       				$(this).tree('select', selectedNode.target);
       			}
       		}
        }
    });
    //数据列表
    resource_datagrid = $('#resource_datagrid').datagrid({
	    url:'${ctx}/base/resource!datagrid.action',
	    pagination:true,//底部分页
	    pagePosition:'bottom',//'top','bottom','both'.
	    rownumbers:true,//显示行数
	    fitColumns:true,//自适应列宽
	    striped:true,//显示条纹
	    pageSize:20,//每页记录数
        remoteSort:false,//是否通过远程服务器对数据排序
		sortName:'orderNo',//默认排序字段
		sortOrder:'asc',//默认排序方式 'desc' 'asc'
		idField : 'id',
		columns:[[  
            {field:'ck',checkbox:true,width:60},
            {field:'id',title:'主键',hidden:true,sortable:true,align:'right',width:80}, 
            {field:'ico',title:'图标',width:60,align:'center',formatter:function(value,rowData,rowIndex){
	            	return $.formatString('<span class="tree-icon tree-file {0}"></span>', value);
		           // return "<div style='text-align:center;'><img src='${ctx}/img/resource/"+value +"' border='0' width='20px' height='20px'></div>";
	            }
            },
	        {field:'name',title:'资源名称',width:120},
            {field:'code',title:'资源编码',width:120},
	        {field:'url',title:'链接地址',width:260},
            {field:'markUrl',title:'标识地址',width:200},
	        {field:'orderNo',title:'排序',align:'right',width:60,sortable:true},
            {field:'typeDesc',title:'资源类型',align:'center',width:100},
	        {field:'statusDesc',title:'状态',align:'center',width:60}
	    ]],
	    onLoadSuccess:function(){
	    	$(this).datagrid('clearSelections');//取消所有的已选择项
	    	$(this).datagrid('unselectAll');//取消全选按钮为全选状态
	    	//鼠标移动提示列表信息tooltip
			$(this).datagrid('showTooltip');
            //表头居中
            //eu.datagridHeaderCenter();
        },
	    onRowContextMenu : function(e, rowIndex, rowData) {
			e.preventDefault();
			$(this).datagrid('unselectAll');
			$(this).datagrid('selectRow', rowIndex);
			$('#resource_datagrid_menu').menu('show', {
				left : e.pageX,
				top : e.pageY
			});
		}
	});

    loadResourceType();
});

		//设置排序默认值
		function setSortValue(){
			$.get('${ctx}/base/resource!maxSort.action',function(data){
				if (data.code==1){
					$('#orderNo').numberspinner('setValue',data.obj+1);
				} 
			},'json');
		}
		
		function formInit(){
			resource_form = $('#resource_form').form({
				url: '${ctx}/base/resource!save.action',
				onSubmit: function(param){  
					param.replace = 1; //是否过滤特殊字符
					$.messager.progress({
						title : '提示信息！',
						text : '数据处理中，请稍后....'
					});
					var isValid = $(this).form('validate');
					if (!isValid) {
						$.messager.progress('close');
					}
					return isValid;
			    },
				success: function(data){
					$.messager.progress('close');
					var json = $.parseJSON(data);
					//var json = eval('('+ data+')'); //将后台传递的json字符串转换为javascript json对象 
					if (json.code ==1){
						resource_dialog.dialog('destroy');//销毁对话框
						resource_tree.tree('reload'); //重新加载树
						resource_datagrid.datagrid('reload');//重新加载列表数据
						eu.showMsg(json.msg);//操作结果提示
					}else if(json.code == 2){
						$.messager.alert('提示信息！', json.msg, 'warning',function(){
							if(json.obj){
								$('#resource_form input[name="'+json.obj+'"]').focus();
							}
						});
					}else {
						eu.showAlertMsg(json.msg,'error');
					}
				}
			});
		}
		//显示弹出窗口 新增：row为空 编辑:row有值 
		function showDialog(row){
			//弹出对话窗口
			//resource_dialog = parent.$('<div/>').dialog({//基于父对象的对话框(全屏遮罩的效果)
			resource_dialog = $('<div/>').dialog({//基于中心面板
				title:'资源详细信息',
				width : 500,
				height : 360,
				modal : true,
				maximizable:true,
				href : '${ctx}/base/resource!input.action',
				buttons : [ {
					text : '保存',
					iconCls : 'icon-save',
					handler : function() {
						resource_form.submit();
					}
				},{
					text : '关闭',
					iconCls : 'icon-cancel',
					handler : function() {
						resource_dialog.dialog('destroy');
					}
				}],
				onClose : function() {
					$(this).dialog('destroy');
				},
				onLoad:function(){
					formInit();
					if(row){
						resource_form.form('load', row);
					}else{
						$("input[name=status]:eq(0)").attr("checked",'checked');//状态 初始化值
						setSortValue();
					}
				}
			}).dialog('open');
		}
		
		//编辑
		function edit(){
			//选中的所有行
			var rows = resource_datagrid.datagrid('getSelections');
			//选中的行（第一次选择的行）
			var row = resource_datagrid.datagrid('getSelected');
			if (row){
				if(rows.length>1){
					row = rows[rows.length-1];
					eu.showMsg("您选择了多个操作对象，默认操作最后一次被选中的记录！");
				}
				showDialog(row);
			}else{
				eu.showMsg("请选择要操作的对象！");
			}
		}
		//删除
		function del(){
			var rows = resource_datagrid.datagrid('getSelections');
			if(rows.length >0){
				$.messager.confirm('确认提示！','您确定要删除当前选中的所有行(未被选中的子资源也将一起删除)?',function(r){
					if (r){
						var ids = new Object();
						for(var i=0;i<rows.length;i++){
							ids[i] = rows[i].id;
						}
						$.post('${ctx}/base/resource!remove.action',{ids:ids},function(data){
							if (data.code==1){
								resource_tree.tree('reload');  //重新加载树
								resource_datagrid.datagrid('load');//重新加载列表数据
								eu.showMsg(data.msg);//操作结果提示
							} else {
								eu.showAlertMsg(data.msg,'error');
							}
						},'json');      
						
					}
				});
			}else{
				eu.showMsg("请选择要操作的对象！");
			}
		}

        //搜索输入框加载资源类型
        function loadResourceType(){
            $('#filter_EQI_type').combobox({
                url:'${ctx}/base/resource!resourceTypeCombobox.action?selectType=all',
                multiple:false,//是否可多选
                editable:false,//是否可编辑
                width:120,
                valueField:'value',
                displayField:'text'
            });
        }
		//搜索
		function search(){
        	var name = $('#filter_LIKES_name').val();//搜索条件 资源名称
        	var node = resource_tree.tree('getSelected');//
            var type = $('#filter_EQI_type').combobox('getValue');
        	var id = '';
        	if(node != null){
        		id = node.id; //搜索 id:主键 即是通过左边资源树点击得到搜索结果
        	}
        	//将整个表单的数据作为查询条件 
        	//resource_datagrid.datagrid('load',$.serializeObject(resource_search_form));
        	resource_datagrid.datagrid('load',{filter_EQL_id_OR_parentResource__id:id,filter_LIKES_name:name,filter_EQI_type:type});
		}
</script>
<div class="easyui-layout" fit="true" style="margin: 0px;border: 0px;overflow: hidden;width:100%;height:100%;">

	<%-- 左边部分 资源树形 --%>
	<div data-options="region:'west',title:'资源列表',split:false,collapsed:false,border:false"
		style="width: 150px; text-align: left;padding:5px;">
			<ul id="resource_tree"></ul>
	</div>
	
	<%-- 中间部分 列表 --%>
	<div data-options="region:'center',split:false,border:false" 
		style="padding: 0px; height: 100%;width:100%; overflow-y: hidden;">
		
		<%-- 列表右键 --%>
		<div id="resource_datagrid_menu" class="easyui-menu" style="width:120px;display: none;">
			<div onclick="showDialog();" data-options="iconCls:'icon-add'">新增</div>
			<div onclick="edit();" data-options="iconCls:'icon-edit'">编辑</div>
			<div onclick="del();" data-options="iconCls:'icon-remove'">删除</div>
		</div>
		
	   <%-- 工具栏 操作按钮 --%>
	   <div id="resource_datagrid-toolbar">
	        <div style="margin-left:5px; float: left;">
		        <form id="resource_search_form" style="padding: 0px;">
                    资源名称:<input type="text" id="filter_LIKES_name" name="filter_LIKES_name" maxLength="8" placeholder="请输入资源名称..." style="width: 160px"></input>

                    资源类型:<input id="filter_EQI_type" name="filter_EQI_type" class="easyui-combobox"/>
                    <a href="javascript:search();" class="easyui-linkbutton"
							iconCls="icon-search" plain="true" >查 询</a>
				</form>
			</div>
			<div align="right">
				<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true" onclick="showDialog();">新增</a>
				<span class="toolbar-btn-separator"></span>
				<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-edit',plain:true" onclick="edit()">编辑</a>
				<span class="toolbar-btn-separator"></span>
				<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-remove',plain:true" onclick="del()">删除</a> 
			</div>
		</div>
	   <table id="resource_datagrid" toolbar="#resource_datagrid-toolbar" fit="true"></table>
	</div>
</div>
