<!DOCTYPE html>
<html lang="en-us">
  <head>
    <?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloHead.html");?>
  </head>
  <body class="mfgproIndexBody">
    <!-- Dark overlay element -->
    <div class="overlay" id="overlay"></div>

  	<!--NavBar/Header-->
    <div class="all-gp-sloHeader" id="mfgproHeader"><?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloHeader.html"); ?></div>

  	<!--SideBar-->
  	<?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloSidebar.html");?>

    <div class="gp-slo-container container" id="mfgproMainContainer" align="center">
      <table class="table mfgproTable">
        <thead>
          <tr>
            <th>Documentation</th>
            <th>Data from MFGPRO</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><a href="mfgprodocs/index.htm">MFGPRO 9.0 Documentation</a></td>
            <td>
              <h6><a href="http://nd-wind.entegris.com/mfgpro/prodstruct.asp?item=4100037">Product Structure</a></h6>
              <form method="GET" action="searchresults.asp">
                <table>
                  <tr>
                    <td><big><b>Item:</b></big></td>
                    <td><input type="text" name="item" size="18"></td>
                    <td rowspan="2"><input type="submit" value="Lookup" name="B1"></td>
                  </tr>
                  <tr>
                    <td align="right"><big><b>Desc:</b></big></td>
                    <td><input type="text" NAME="desc" SIZE="18" MAXLENGTH="24"></td>
                  </tr>
                </table>
                <input type="hidden" name="ret" value="prodstruct.asp">
              </form>
            </td>
          </tr>
          <tr>
            <td><a href="http://nd-wind.entegris.com/mfgpro/">MFGPRO 9.0 Service Pack 6 Documentation</a></td>
            <td>
              <h6><a href="item.asp?item=4100037">Item Detail</a></h6>
              <form NAME="ITEM" ACTION="searchresults.asp" METHOD="GET">
                <table border="0" cellpadding="2">
                  <tr>
                    <td><big><b>Item:</b></big></td>
                    <td><input type="text" NAME="item" SIZE="18" MAXLENGTH="18"></td>
                    <td rowspan="2"><input TYPE="SUBMIT" VALUE="Lookup"></td>
                  </tr>
                  <tr>
                    <td><big><b>Desc:</b></big></td>
                    <td><input type="text" NAME="desc" SIZE="18" MAXLENGTH="24"></td>
                  </tr>
                </table>
                <input type="hidden" name="ret" value="item.asp">
              </form>
            </td>
          </tr>
          <tr>
            <td><a href="intranetdrawing.doc">How to Use Drawings on the Intranet</a></td>
            <td>
              <h6><a href="parents.asp?item=4100037">Parent Items</a></h6>
              <form NAME="PAR" ACTION="searchresults.asp" METHOD="GET">
                <table>
                  <tr>
                    <td><b><big>Item:</big></b></td>
                    <td><input type="text" NAME="item" SIZE="18" MAXLENGTH="18"></td>
                    <td rowspan="2"><input TYPE="SUBMIT" VALUE="Lookup"></td>
                  </tr>
                  <tr>
                    <td><b><big>Desc:</big></b></td>
                    <td><input type="text" NAME="desc" SIZE="18" MAXLENGTH="24"></td>
                  </tr>
                </table>
                <input type="hidden" name="ret" value="parents.asp">
              </form>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
	
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
