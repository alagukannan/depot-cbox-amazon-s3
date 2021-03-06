<cfoutput>
<h1><img src="includes/images/disks.png" alt="disks" /> 
	<a href="#event.buildLink(linkTo='explorer')#" title="My Amazon S3 Buckets">My Amazon S3 Buckets</a>
	> <a href="#event.buildLink(linkTo='bucket',queryString="#urlEncodedFormat(rc.bucketname)#")#" title="#rc.bucketName# Bucket">#rc.bucketName#</a>
		<cfif listlen(rc.foldername) gt 0>
			<cfset folderPath = "">
			<cfloop list="#rc.foldername#" delimiters="/" index="i">
				<cfset folderPath = listAppend(folderPath,i,"|")>
				> 
				<a href="#event.buildLink(linkTo="bucket",queryString="#urlEncodedFormat(rc.bucketname)#")#/#urlencodedFormat(folderPath)#" title="#i# Folder">#i#</a>
			</cfloop>
		</cfif>	
</h1>

#getPlugin("Messagebox").renderit()#

<div id="bucketChooser">
	<label for="changeBucket"> Jump To: &nbsp;
	<select name="changeBucket" id="changeBucket" onChange="window.location.href='#event.buildLink(linkTo='bucket')#/'+this.value">
		<cfloop array="#rc.allBuckets#" index="bucket">
			<option value="#urlEncodedFormat(bucket.name)#"
				    <cfif comparenocase(bucket.name,rc.bucketname) eq 0>selected="selected"</cfif>>#bucket.name#</option>
		</cfloop>
	</select>
	</label>
</div>

<div id="button-bar">
	<ul>
		<li>
			<a href="#event.buildLink('explorer')#" class="hotbutton">
				<span><img src="includes/images/arrow-return.png" alt="return" border="0" /> Go Back</span>
			</a>
		</li>
		<li>
			<a href="javascript:window.location.reload()" class="hotbutton">
				<span><img src="includes/images/reload.png" alt="reload" border="0" /> Reload</span>
			</a>
		</li>
		<li>
			<a href="javascript:uploadObject()" class="hotbutton">
				<span><img src="includes/images/upload.png" alt="upload" border="0" /> Upload File</span>
			</a>
		</li>
		<li>
			<a href="javascript:uploadFolder()" class="hotbutton">
				<span><img src="includes/images/add.png" alt="upload" border="0" /> Create Folder</span>
			</a>
		</li>
		<li>
			<a href="#event.buildLink(linkTo='explorer.docs')#" class="hotbutton">
				<span><img src="includes/images/help.png" alt="reload" border="0" /> API Help</span>
			</a>
		</li>
	</ul>
</div>

<!--- Generic Dialog --->
<div id="dialog"><img src="includes/images/ajax-loader.gif" alt="loader" id="ajaxLoader" /></div>

<!--- Delete Dialog --->
<div id="deleteDialog">
	<h3>This object will be permanently deleted and cannot be recovered. Are you sure?</h3>
	<form action="#event.buildLink('explorer.removeObject')#" method="post">
		<input type="hidden" name="bucketName" id="bucketName" value="#rc.bucketName#" />
		<input type="hidden" name="uri" id="uri" value="" />		
		  <p align="center">
			  <input type="submit" name="submit" value="Yes" />
			  <input type="button" name="Close" value="No" class="simplemodal-close" />
		  </p>		
	</form>
</div>

<!--- Upload Dialog --->
<div id="uploadDialog">
<form action="#event.buildLink('explorer.upload')#" method="post" enctype="multipart/form-data">
<input type="hidden" name="bucketName" id="bucketName" value="#rc.bucketName#" />
<input type="hidden" name="folderName" id="folderName" value="#rc.folderName#" />
<fieldset>
	<legend>Upload Object</legend>
	
	<input type="file" name="fileobject" size="30" />
	
	<label for="acl">ACL</label>
	<select name="acl" id="acl">
		<option>private</option>
		<option selected="selected">public-read</option>
		<option>public-read-write</option>
		<option>authenticated-read</option>
	</select>
	
	<label for="cc">Extra Metadata (As a JSON struct)</label> <em>Ex: {name:'luis',awesome:'true'} <br/>
	<input type="text" value="{}" name="extraMetadata" id="extraMetadata" size="40"/>
	
	
	<label for="cc">Cache Control String</label>
	<input type="text" value="" name="cc" id="cc" size="40"/>
	
	<label for="cc">Days to Expire</label>
	<input type="text" value="" name="expires" id="expires" size="10"/>
	
	<br/><br/>
	
	<br/>
	<div id="actionBar">
		<input type="button" class='simplemodal-close' onClick='$.modal.close()' value="Cancel" />
		<input type="submit" name="uploadFile" value="Upload File" />
	</div>
</fieldset>
</form>	
</div>

<!--- Upload Folder Dialog --->
<div id="uploadFolderDialog">
<form action="#event.buildLink('explorer.createFolder')#" method="post" enctype="multipart/form-data">
<input type="hidden" name="bucketName" id="bucketName" value="#rc.bucketName#" />

<fieldset>
	<legend>Folder Path</legend>
	
	<input type="text" name="folderName" id="folderName" value="#rc.folderName#" size="50" />
	<label for="acl">ACL</label>
	<select name="acl" id="acl">
		<option>private</option>
		<option selected="selected">public-read</option>
		<option>public-read-write</option>
		<option>authenticated-read</option>
	</select>
	<br/><br/>

	<div id="actionBar">
		<input type="button" class='simplemodal-close' value="Cancel" />
		<input type="submit" name="uploadFolder" value="Create Folder" />
	</div>
</fieldset>
</form>	
</div>
<table class="tablesorter" id="bucketsTable">
<thead>
<tr>
	<th>Object Name</th>
	<th width="150">Last Modified</th>
	<th width="100">Size</th>
	<th width="200">eTag</th>
	<th class="center {sorter:false}" width="165">Actions</th>
</tr>
</thead>
<tbody>
<cfloop array="#rc.allObjects#" index="object">
<cfset encodedObjectKey = urlencodedFormat(replacelist(object.Key,'/,_$folder$','|,'))>
<tr>
	<td>
		<cfif findNoCase("_$folder$",object.key)>
			<a href="#event.buildLink(linkTo="explorer.viewBucket",queryString="bucketName=#urlEncodedFormat(rc.bucketname)#")#/folderName/#encodedObjectKey#" title="Public Link">
				<img src="includes/images/folder.gif" alt="folder" border="0" /> #replacenocase(object.Key,'_$folder$','')#
			</a>
		<cfelse>
			<a target="_blank" href="http://#rc.bucketName#.s3.amazonaws.com/#object.key#" title="Public Link">
				<img src="includes/images/file.png" alt="file" border="0" /> #object.Key#
			</a>
		</cfif>
	</td>
	<td>
		#dateFormat(getPlugin("DateUtils").parseISO8601(object.LastModified),"mm/dd/yyyy")#
		#timeFormat(getPlugin("DateUtils").parseISO8601(object.LastModified),"hh:mm tt")#
	</td>	
	<td>#NumberFormat(object.Size/1024)# KB</td>
	<td>#replace(object.etag,'"','',"all")#</td>
	<td class="center"> 
		<cfif findNoCase("_$folder$",object.key) eq 0>
			<a href="javascript:secureLink('#urlEncodedFormat(object.key)#')" title="Time Expired Link">
				<img src="includes/images/link.png" border="0" alt="secure link" />
			</a> 
		</cfif>
		&nbsp;
		<a href="javascript:showACL('#urlEncodedFormat(rc.bucketname)#/#urlEncodedFormat(object.key)#')"
		   title="Show bucket ACL">
			<img src="includes/images/security.png" border="0" alt="security" />
		</a>
		&nbsp;
		<a href="javascript:getObjectInfo('#URLEncodedFormat(object.Key)#')" title="Get Object Metadata">
			<img src="includes/images/info.png" border="0" alt="" /> 
		</a>
		&nbsp;
		<cfif findNoCase("_$folder$",object.key) eq 0>
			<a href="javascript:copyObject('#URLEncodedFormat(object.Key)#')" title="Copy Object">
				<img src="includes/images/copy.png" border="0" alt="" /> 
			</a>
			&nbsp;
			<a href="javascript:void(0);" rel="#urlEncodedFormat(object.key)#" class="removeObject" title="Remove Object">
				<img src="includes/images/delete.png" border="0" alt="" />   
			</a>
		</cfif>
</tr>
</cfloop>
</tbody>
</table>

<cfif arrayLen(rc.allObjects) eq 0>
<em>No objects found in bucket/folder</em>
</cfif>
<script type="text/javascript">
$(document).ready(function() {
	$("##bucketsTable").tablesorter();
	
	//removeObject listener
	$(".removeObject").click(function(){
		var uri = $(this).attr("rel");
		$("##deleteDialog ##uri").val(uri);
		$("##deleteDialog").modal({minWidth:275,minHeight:125,overlayClose:true});
		return false;
	});
});

var closeHTML = "<p><button class='simplemodal-close' onClick='$.modal.close()'>Close-Cancel</button> <span>(or press ESC to cancel)</span></p>";
	
function uploadObject(){
	$("##uploadDialog").modal({minWidth:500,overlayClose:true});
}
function uploadFolder(){
	$("##uploadFolderDialog").modal({minWidth:500,overlayClose:true});
}
function getObjectInfo(obj){
	var data = {bucketName:"#rc.bucketName#",
				objectKey:obj};
	$("##dialog").load('#event.buildLink("explorer.getObjectInfo")#',
						data,
						function(){
							$(this).append(closeHTML);
						}).modal({minWidth:650,minHeight:400,overlayClose:true});
}
function secureLink(obj){
	var data = {bucketName:"#rc.bucketName#",
				key:encodeURI(obj)};
	$("##dialog").load('#event.buildLink("explorer.genAuthenticatedURL")#',
						data,
						function(){
							$(this).append(closeHTML);
						}).modal({minWidth:500,overlayClose:true});
}
function copyObject(obj){
	var data = {fromBucket:"#rc.bucketName#",
				fromURI:obj};
	$("##dialog").load('#event.buildLink("explorer.copyDialog")#',
						data,
						function(){
							$(this).append(closeHTML);
						}).modal({minWidth:600,minHeight:450,overlayClose:true});
}
function showACL(bucket){
	var data = {objectName:bucket};
	$("##dialog").load('#event.buildLink("explorer.objectACL")#',
						data,
						function(){
							$(this).append(closeHTML);
						}).modal({minWidth:600,overlayClose:true});
}
</script>
</cfoutput>