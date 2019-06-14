<!DOCTYPE html>
<html lang="en-us">
  <head>
    <?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloHead.html");?>
  </head>

  <body>
    <!-- Dark overlay element -->
    <div class="overlay" id="overlay"></div>

  	<!--NavBar/Header-->
    <div class="all-gp-sloHeader" id="supplierSearchHeader"><?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloHeader.html"); ?></div>

  	<!--SideBar-->
  	<?php include("http://nd-wind.entegris.com/gp-slo/common/gp-sloSidebar.html");?>
    <br>
    <div class="gp-slo-container container" id="supSearchMainContainer">
      <div class="row justify-content-md-center">
        <table border="2">
          <tr>
            <td>
              <form method="POST" action="supplierSearchResults.asp">
                <table>
                  <tr>
                    <td><big>Search Criteria:</big></td>
                    <td><input type="text" name="search" size="20"></td>
                  </tr>
                  <tr>
                    <td align="right"><input type="checkbox" name="exact" value="ON"></td>
                    <td><big>Exact match Only? </big>(<em>faster</em>)</td>
                  </tr>
                  <tr>
                    <td colspan="2" align="center"></td>
                  </tr>
                  <tr>
                    <td colspan="2" align="center"><input type="submit" value="Submit" name="B1"> <input type="reset" value="Reset" name="B2"></td>
                  </tr>
                </table>
              </form>
            </td>
          </tr>
        </table>
      </div>
    </div>


  <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
  	<script type="text/javascript">
        $(document).ready(function () {
          $('#pageTitleDiv').html("");
          $('#pageTitleDiv').html("<h5>Supplier Search</h5>");
		  $('#shortPageTitleDiv').html("");
		  $('#shortPageTitleDiv').html("<h5>Sup Srch.</h5>");
        })
    </script>
  </body>
</html>
