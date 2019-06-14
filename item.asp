<%	Response.Buffer = true
	Server.ScriptTimeout = 10000 
%>
<!DOCTYPE html>
<html lang="en-us">
	<head>
		<!-- #include file = "../gp-slo/common/gp-sloHead.html" -->
	</head>
	<body class="mfgproBody">
		<!-- Dark overlay element -->
		<div class="overlay" id="overlay"></div>

		<!--NavBar/Header-->
		<div class="all-gp-sloHeader" id="itemHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		
		<%	Set Conn = Server.CreateObject("ADODB.Connection")
				Conn.ConnectionString = "DSN=SPG;UID=mfg;PWD="
			Conn.Open SPG
			set itemRS = Conn.Execute("Select pt_desc1, pt_desc2, pt_draw, pt_rev from PUB.pt_mstr where pt_domain = 'SPG' and pt_part = '" & Request("item") & "'")
			if itemRS.eof then Response.Redirect "searchresults.asp?item=" & Server.URLEncode(Request("item")) & "&desc=" & Server.URLEncode(Request("desc")) & "&ret=item.asp"
		%>

		<h5 align="center"><a href="item.asp?item=<%=Server.URLEncode(request("item"))%>"><%=Request("item")%></a> <small><%=itemRS("pt_desc1") & " " & itemRS("pt_desc2") & "</small>"%> <%
			part = request("item")
			revision = itemRS("pt_rev")
			drawing = getDrawing(part, revision)
			Response.Write " <small><small>[ "
			if drawing <> "" then Response.Write "<a href=""/Department/doc_con/DWG/REL/" & drawing & """>Drawing</a> | "
			Response.Write " <a href=""parents.asp?item=" & Server.URLEncode(part) & """>Parents</a> ]</small></small>" & vbCrLf
			%>
		</h5>
		<%
			itemRS.Close
			set itemRS = Nothing
			
			set ptRS = Conn.Execute("select * from PUB.pt_mstr where pt_domain = 'SPG' and pt_part = '" & part & "'")
			set qohRS = Conn.Execute("select in_qty_oh, in_qty_all, in_qty_ord from PUB.in_mstr " & _
				" where in_domain = 'SPG' and in_site = 'AA00' and in_part = '" & part & "'")
			if not qohRS.eof then
				qtyoh = qohRS(0)
				qtyavail = CDbl(qohRS(0)) - CDbl(qohRS(1))
				qtyord = qohRS(2)
			else
				qtyoh = 0
				qtyavail = 0
				qtyord = 0
			end if
			qohRS.close
			set qohRS = Nothing

		%>
		</small><div align="center"><center>

		<table border="0" cellpadding="2">
		  <tr>
			<td align="center"><big><strong>Item Data</strong></big><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="right"><strong>Product Line:</strong></td>
					<td><small><%=ptRS("pt_prod_line")%></small></td>
					<td align="right"><strong>Item Type:</strong></td>
					<td><small><%=ptRS("pt_part_type")%></small></td>
					<td align="right"><strong>Drawing:</strong></td>
					<td colspan="3"><small><%=ptRS("pt_draw")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Added:</strong></td>
					<td><small><%=ptRS("pt_added")%></small></td>
					<td align="right"><strong>Status:</strong></td>
					<td><small><%=ptRS("pt_status")%></small></td>
					<td align="right"><strong>Rev:</strong></td>
					<td colspan="3"><small><%=ptRS("pt_rev")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>UM:</strong></td>
					<td><small><%=ptRS("pt_um")%></small></td>
					<td align="right"><strong>Group:</strong></td>
					<td><small><%=ptRS("pt_group")%></small></td>
					<td align="right"><strong>Drawing Loc:</strong></td>
					<td><small><%=ptRS("pt_drwg_loc")%></small></td>
					<td align="right"><strong>Rev</strong>:</td>
					<td><small><%=ptRS("pt_rev")%></small></td>
				  </tr>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Inventory Data</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="right"><strong>ABC Class:</strong></td>
					<td><small><%=ptRS("pt_abc")%></small></td>
					<td align="right"><strong>Avg Int:</strong></td>
					<td><small><%=ptRS("pt_avg_int")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Lot/Serial Control:</strong></td>
					<td><small><%=ptRS("pt_lot_ser")%></small></td>
					<td align="right"><strong>Cyc Cnt Int:</strong></td>
					<td><small><%=ptRS("pt_cyc_int")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Site:</strong></td>
					<td><small><%=ptRS("pt_site")%></small></td>
					<td align="right"><strong>Shelf Life:</strong></td>
					<td><small><%=ptRS("pt_shelflife")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Location:</strong></td>
					<td><small><%=ptRS("pt_loc")%></small></td>
					<td align="right"><strong>Allocate Single Lot:</strong></td>
					<td><small><%=ptRS("pt_sngl_lot")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Location Type:</strong></td>
					<td><small><%=ptRS("pt_loc_type")%></small></td>
					<td align="right"><strong>Critical Item:</strong></td>
					<td><small><%=ptRS("pt_critical")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Auto Lot Numbers:</strong></td>
					<td><small><%=ptRS("pt_auto_lot")%></small></td>
					<td align="right"></td>
					<td></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Article Number:</strong></td>
					<td><small><%=ptRS("pt_article")%></small></td>
					<td align="right"></td>
					<td></td>
				  </tr>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Italian Data</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="right"><strong>Parent Part:</strong></td>
					<td><small><%=ptRS("pt__chr03")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Group:</strong></td>
					<td><small><%=ptRS("pt__chr02")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Application:</strong></td>
					<td><small><%=ptRS("pt__chr01")%></small></td>
				  </tr>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Planning Data</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="right"><strong>Master Sched:</strong></td>
					<td><small><%=ptRS("pt_ms")%></small></td>
					<td align="right"><strong>Buyer/Planner:</strong></td>
					<td><small><%=ptRS("pt_buyer")%></small></td>
					<td align="right" colspan="4"><strong>Issue Policy:</strong></td>
					<td><small><%=ptRS("pt_iss_pol")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Plan Orders:</strong></td>
					<td><small><%=ptRS("pt_plan_ord")%></small></td>
					<td align="right"><strong>Supplier:</strong></td>
					<td><small><%=ptRS("pt_vend")%></small></td>
					<td align="right" colspan="4"><strong>Phantom:</strong></td>
					<td><small><%=ptRS("pt_phantom")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Time Fence:</strong></td>
					<td><small><%=ptRS("pt_timefence")%></small></td>
					<td align="right"><strong>PO Site:</strong></td>
					<td><small><%=ptRS("pt_po_site")%></small></td>
					<td align="right" colspan="4"><strong>Min Order:</strong></td>
					<td><small><%=ptRS("pt_ord_min")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>MRP Required:</strong></td>
					<td><small><%=ptRS("pt_mrp")%></small></td>
					<td align="right"><strong>Pur/Mfg:</strong></td>
					<td><small><%=ptRS("pt_pm_code")%></small></td>
					<td align="right" colspan="4"><strong>Max Order:</strong></td>
					<td><small><%=ptRS("pt_ord_max")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Order Policy:</strong></td>
					<td><small><%=ptRS("pt_ord_pol")%></small></td>
					<td align="right"><strong>Mfg LT:</strong></td>
					<td><small><%=ptRS("pt_mfg_lead")%></small></td>
					<td align="right" colspan="4"><strong>Order Mult:</strong></td>
					<td><small><%=ptRS("pt_ord_mult")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Order Qty:</strong></td>
					<td><small><%=ptRS("pt_ord_qty")%></small></td>
					<td align="right"><strong>Pur LT:</strong></td>
					<td><small><%=ptRS("pt_pur_lead")%></small></td>
					<td align="right" colspan="4"><strong>Yield %:</strong></td>
					<td><small><%=ptRS("pt_yield_pct")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Batch Qty:</strong></td>
					<td><small><%=ptRS("pt_batch")%></small></td>
					<td align="right"><strong>Inspect:</strong></td>
					<td><small><%=ptRS("pt_insp_rqd")%></small></td>
					<td align="right" colspan="4"><strong>Run Time:</strong></td>
					<td><small><%=ptRS("pt_run")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Order Period:</strong></td>
					<td><small><%=ptRS("pt_ord_per")%></small></td>
					<td align="right"><strong>Ins LT:</strong></td>
					<td><small><%=ptRS("pt_insp_lead")%></small></td>
					<td align="right" colspan="4"><strong>Setup Time:</strong></td>
					<td><small><%=ptRS("pt_setup")%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Safety Stk:</strong></td>
					<td><small><%=ptRS("pt_sfty_stk")%></small></td>
					<td align="right"><strong>Cum LT:</strong></td>
					<td colspan="2"><small><%=ptRS("pt_cum_lead")%></small></td>
					<td colspan="4" align="center" bgcolor="#FFFF00"><strong><u>Quantities</u></strong></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Safety Time:</strong></td>
					<td><small><%=ptRS("pt_sfty_time")%></small></td>
					<td align="right"><strong>Network Code:</strong></td>
					<td colspan="2"><small><%=ptRS("pt_network")%></small></td>
					<td colspan="2" align="right" bgcolor="#FFFF00"><small>On Hand:</small></td>
					<td colspan="2" bgcolor="#FFFF00"><small><%=qtyoh%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Reorder Point:</strong></td>
					<td><small><%=ptRS("pt_rop")%></small></td>
					<td align="right"><strong>Routing Code:</strong></td>
					<td colspan="2" align="right"><small><%=ptRS("pt_routing")%></small></td>
					<td colspan="2" align="right" bgcolor="#FFFF00">Available:</td>
					<td colspan="2" bgcolor="#FFFF00"><small><%=qtyavail%></small></td>
				  </tr>
				  <tr>
					<td align="right"><strong>Revision:</strong></td>
					<td><small><%=ptRS("pt_rev")%></small></td>
					<td align="right"><strong>Bill of Material:</strong></td>
					<td colspan="2"><small><%=ptRS("pt_bom_code")%></small></td>
					<td colspan="2" align="right" bgcolor="#FFFF00"><small>On Order:</small></td>
					<td colspan="2" bgcolor="#FFFF00"><small><%=qtyord%></small></td>
				  </tr>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br><big>Supplier Information</big>
				<div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><table border="0" cellpadding="2">
				  <tr>
					<strong>
					<td><strong>Vendor</strong></td>
					</strong>
					<td><strong>Vendor Part</strong></td>
					<td><b>Mfg</b></td>
				  </strong>
					<td><b>Mfg Part</b></td>
					</tr>
				  <strong>
				<%	set vRS = Conn.Execute("select * from PUB.vp_mstr where vp_domain = 'SPG' and vp_part = '" & part & "'")
					do while not vRS.eof
						if vRS("vp_vend") <> "" then
							set vdRS = Conn.Execute("select vd_sort from PUB.vd_mstr where vd_domain = 'SPG' and vd_addr = '" & vRS("vp_vend") & "'")
							if not vdRS.eof then vendname = vdRS("vd_sort") else vendname = ""
							vdRS.close
							set vdRS = Nothing
						else
							vendname = ""
						end if
				%>
				  <tr>
					<td><%=vendname & " (" & vRS("vp_vend") & ")"%></td>
					<td><%=vRS("vp_vend_part")%></td>
					<td><%=vRS("vp_mfgr")%></td>
					<td><%=vRS("vp_mfgr_part")%></td>
					</tr>
					<%		vRS.MoveNext
						Loop
						vRS.Close
						Set vRS = Nothing
					%>
					</table>
				 </td>
				</tr>
			</table></div
			 </strong>
			  </strong></center>
			</td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Price Data</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><table border="0" cellpadding="2">
				  <tr>
					<td align="right"><strong>Price:</strong></td>
					<td><small><%=ptRS("pt_price")%></small></td>
					<td align="right"><strong>Tax:</strong></td>
					<td><small><%=ptRS("pt_taxable")%></small></td>
					<td align="right"><strong>Tax Class:</strong></td>
					<td><small><%=ptRS("pt_taxc")%></small></td>
				  </tr>
				</table>
				</td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Standard Cost</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="center"><strong>Element</strong></td>
					<td align="center"><strong>This Level</strong></td>
					<td align="center"><strong>Lower Level</strong></td>
					<td align="center"><strong>Total</strong></td>
				  </tr>
		<%
			set sctRS = Conn.Execute("Select * from PUB.sct_det where sct_domain = 'SPG' and sct_part = '" & part & "' and sct_site = 'AA00' and sct_sim = 'STANDARD'")
			set sptRS = Conn.Execute("select * from PUB.spt_det " & _
					" where spt_domain = 'SPG' and spt_part = '" & part & "' and spt_site = 'AA00' and spt_sim = 'STANDARD' order by spt_element")
			do while not sptRS.eof
		%>
		<tr>
					<td><strong><%=sptRS("spt_element")%></strong></td>
					<td align="right"><small><%=formatNumber(sptRS("spt_cst_tl"),2)%></small></td>
					<td align="right"><small><%=formatNumber(sptRS("spt_cst_ll"),2)%></small></td>
					<td align="right"><small><%=formatNumber(CDbl(sptRS("spt_cst_tl")) + CDbl(sptRS("spt_cst_ll")),2)%></small></td>
				  </tr>
		<%		sptRS.MoveNext
			Loop
			sptRS.Close
			set sptRS = Nothing
		%>
				  <tr>
					<td align="right"><strong>Total:</strong></td>
					<td align="right"><strong><%=formatNumber(CDbl(sctRS("sct_mtl_tl")) + CDbl(sctRS("sct_bdn_tl")) + CDbl(sctRS("sct_lbr_tl")) + CDbl(sctRS("sct_sub_tl")) + CDbl(sctRS("sct_ovh_tl")), 2)%></strong></td>
					<td align="right"><strong><%=formatNumber(CDbl(sctRS("sct_mtl_ll")) + CDbl(sctRS("sct_bdn_ll")) + CDbl(sctRS("sct_lbr_ll")) + CDbl(sctRS("sct_sub_ll")) + CDbl(sctRS("sct_ovh_ll")), 2)%></strong></td>
					<td align="right"><strong><%=formatNumber(sctRS("sct_cst_tot"),2)%></strong></td>
		</tr>
		<%	sctRS.Close
			set sctRS = Nothing
		%>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		  <tr>
			<td align="center"><strong><br>
			<big>Current Cost</big></strong><div align="center"><center><table border="2" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			  <tr>
				<td><div align="center"><center><table border="0" cellpadding="2">
				  <tr>
					<td align="center"><strong>Element</strong></td>
					<td align="center"><strong>This Level</strong></td>
					<td align="center"><strong>Lower Level</strong></td>
					<td align="center"><strong>Total</strong></td>
				  </tr>
		<%
			set sctRS = Conn.Execute("Select * from PUB.sct_det where sct_domain = 'SPG' and sct_part = '" & part & "' and sct_site = 'AA00' and sct_sim = 'CURRENT'")
			set sptRS = Conn.Execute("select * from PUB.spt_det " & _
					" where spt_domain = 'SPG' and spt_part = '" & part & "' and spt_site = 'AA00' and spt_sim = 'CURRENT' order by spt_element")
			do while not sptRS.eof
		%>
				  <tr>
					<td><strong><%=sptRS("spt_element")%></strong></td>
					<td align="right"><small><%=formatNumber(sptRS("spt_cst_tl"),2)%></small></td>
					<td align="right"><small><%=formatNumber(sptRS("spt_cst_ll"),2)%></small></td>
					<td align="right"><small><%=formatNumber(CDbl(sptRS("spt_cst_tl")) + CDbl(sptRS("spt_cst_ll")),2)%></small></td>
				  </tr>
		<%		sptRS.MoveNext
			Loop
			sptRS.Close
			set sptRS = Nothing
		%>
				  <tr>
					<td align="right"><strong>Total:</strong></td>
					<td align="right"><strong><%=formatNumber(CDbl(sctRS("sct_mtl_tl")) + CDbl(sctRS("sct_bdn_tl")) + CDbl(sctRS("sct_lbr_tl")) + CDbl(sctRS("sct_sub_tl")) + CDbl(sctRS("sct_ovh_tl")), 2)%></strong></td>
					<td align="right"><strong><%=formatNumber(CDbl(sctRS("sct_mtl_ll")) + CDbl(sctRS("sct_bdn_ll")) + CDbl(sctRS("sct_lbr_ll")) + CDbl(sctRS("sct_sub_ll")) + CDbl(sctRS("sct_ovh_ll")), 2)%></strong></td>
					<td align="right"><strong><%=formatNumber(sctRS("sct_cst_tot"),2)%></strong></td>
				  </tr>
		<%	sctRS.Close
			set sctRS = Nothing
		%>
				</table>
				</center></div></td>
			  </tr>
			</table>
			</center></div></td>
		  </tr>
		</table>
		</center></div><small><%	
			ptRS.Close
			set ptRS = Nothing
		%>
		<br>
		<form method="GET" action="searchresults.asp">
			  <div align="center">
				  <table border="2" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
					  <td>
						<div align="center">
							<strong>Item:</strong><input type="text" name="item" size="20" value="<%=Request("item")%>">
							<input type="submit" value="Submit" name="B1"><input type="reset" value="Reset" name="B2">
						</div>
					  </td>
					</tr>
				  </table>
			  </div>
				  <input type="hidden" name="ret" value="item.asp">
		</form>
		<br>
		</small>
		<script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
			$(document).ready(function () {
			  $('#pageTitleDiv').html("");
			  $('#pageTitleDiv').html("<h5>MFGPRO</h5>");
			  $('#shortPageTitleDiv').html("");
			  $('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");
			})			
		</script>
	</body>
</html>
<%
	if isObject(itemRS) then set itemRS = Nothing
	if isObject(ptRS) then set ptRS = Nothing
	Conn.Close	
	Set Conn = Nothing

	function getDrawing(item, rev)
		drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "___" & rev & ".pdf"
		set fs = Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists("K:\Department\doc_con\DWG\REL\" & drawing) then
			getDrawing = replace(drawing, "\", "/")
		else
			drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "_" & rev & ".pdf"
			if fs.FileExists("K:\Department\doc_con\DWG\REL\" & drawing) then
				getDrawing = replace(drawing, "\", "/")
			else
				getDrawing = ""
			end if
		end if
		set fs = Nothing
	end function
%>