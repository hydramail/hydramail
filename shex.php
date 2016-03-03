<!DOCTYPE HTML>
<!--
	Astral by HTML5 UP
	html5up.net | @n33co
	Free for personal and commercial use under the CCA 3.0 license (html5up.net/license)
-->
<html>
	<head>
		<title>Hydramail</title>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<link rel="shortcut icon" href="assets/favicon.ico" type="image/x-icon" />
		<link rel="stylesheet" href="assets/css/main.css" />
		<noscript><link rel="stylesheet" href="assets/css/noscript.css" /></noscript>
	</head>
	<body>

		<!-- Wrapper-->
			<div id="wrapper">

				<!-- Nav -->
					<nav id="nav">
						<a href="http://hydramail.net" class="icon fa-home"><span>Home</span></a>
						<a href="#scl" class="icon fa-cogs active"><span>SCL</span></a>
					</nav>

				<!-- Main -->
					<div id="main">


							
							<!-- SCL -->
							<article id="scl" class="panel">
								<header>
									<h1>ShEx DNS Checker</h1>
								</header>	
								
								<form action="shex.php" method="get">
								Domain: <input type="text" name="domain">
								<input type="submit">
								</form>
								
								<?php
								
								
								if( $_GET["domain"] ) {
									$domain = $_GET['domain'];
									echo "<h2>Results for ". $domain . "</h2>";
									echo "<br />";
								
											
									$var_mx_client = "client.ukfastexchange.co.uk";
									$var_mx_hub1 = "hub1.ukfastexchange.co.uk";
									$var_mx_hub2 = "hub2.ukfastexchange.co.uk";
									$var_mx_hub3 = "hub3.ukfastexchange.co.uk";
									$var_mx_hub4 = "hub4.ukfastexchange.co.uk";
									
									$var_spf = "v=spf1 include:_spf.ukfastexchange.co.uk ~all";
									
									$var_srv_host = "_autodiscover._tcp.".$domain;
									$var_srv_priority = "0";
									$var_srv_weight = "0";
									$var_srv_port = "443";
									$var_srv_target = "client.ukfastexchange.co.uk";
								
								
									//MX								
									$mx_result = dns_get_record($domain, DNS_MX);
									//print_r($mx_result);
																							
									
									$mx_array = array();
									
									
									foreach($mx_result as $key=>$value){
										$mx_entry = $value['target'];
										array_push($mx_array, $mx_entry);
									}
									
									sort($mx_array);
																		
									foreach ($mx_array as $value) {										
										if ($value == "client.ukfastexchange.co.uk")
										{$var_mx_client = "passed";}
									    if  ($value == "hub1.ukfastexchange.co.uk")
										{$var_mx_hub1 = "passed";}
									    if  ($value == "hub2.ukfastexchange.co.uk")
										{$var_mx_hub2 = "passed";}
									    if  ($value == "hub3.ukfastexchange.co.uk")
										{$var_mx_hub3 = "passed";}
									    if  ($value == "hub4.ukfastexchange.co.uk")
										{$var_mx_hub4 = "passed";}
									}
									
									
									
									echo "<h3>MX records</h3>";
									echo "<br />";
									
									if ($var_mx_client == "passed"){echo 'client.ukfastexchange.co.uk - <span class="pass">pass</span>';}
									else{echo 'client.ukfastexchange.co.uk - <span class="fail">fail</span>';}
									echo "<br />";
									if ($var_mx_hub1 == "passed"){echo 'hub1.ukfastexchange.co.uk - <span class="pass">pass</span>';}
									else{echo 'hub1.ukfastexchange.co.uk - <span class="fail">fail</span>';}
									echo "<br />";
									if ($var_mx_hub2 == "passed"){echo 'hub2.ukfastexchange.co.uk - <span class="pass">pass</span>';}
									else{echo 'hub2.ukfastexchange.co.uk - <span class="fail">fail</span>';}
									echo "<br />";
									if ($var_mx_hub3 == "passed"){echo 'hub3.ukfastexchange.co.uk - <span class="pass">pass</span>';}
									else{echo 'hub3.ukfastexchange.co.uk - <span class="fail">fail</span>';}
									echo "<br />";
									if ($var_mx_hub4 == "passed"){echo 'hub4.ukfastexchange.co.uk - <span class="pass">pass</span>';}
									else{echo 'hub4.ukfastexchange.co.uk - <span class="fail">fail</span>';}	


									echo "<br />";
									echo "<br />";
									
									
									
									//SRV
									$srv = "_autodiscover._tcp.".$domain;
									$srv_result = dns_get_record($srv, DNS_SRV);									
									echo "<br />";
									echo "<h3>SRV (Autodiscover) record</h3>";
									echo "<br />";
									if (empty($srv_result)) {
										echo 'Host       - <span class="fail">fail</span><br>';
										echo 'Priotrity  - <span class="fail">fail</span><br>';
										echo 'Weight     - <span class="fail">fail</span><br>';
										echo 'Port       - <span class="fail">fail</span><br>';
										echo 'Target     - <span class="fail">fail</span><br>';
									}
									else{
										
										
										if (count($srv_result) > 1)	{echo '<span class="fail">AUTOMATIC FAILURE - MULTIPLE SRV RECORDS</span></br></br>';}																						
										
										
										
										foreach($srv_result as $srv_key=>$srv_value){
																					
											
										
											if ($srv_value['host'] == $srv)								{echo "Host       : ".$srv_value['host'].' - <span class="pass">pass</span> <br>';}	
																									else{echo "Host       : ".$srv_value['host'].' - <span class="fail">fail</span><br> <br>';}
											if ($srv_value['pri'] == "0")								{echo "Priotrity  : ".$srv_value['pri'].' - <span class="pass">pass</span> <br>';}
																									else{echo "Priotrity  : ".$srv_value['pri'].' - <span class="meh">fail - doesn&#39;t really matter</span><br> <br>';}		
											if ($srv_value['weight'] == "0")							{echo "Weight     : ".$srv_value['weight'].' - <span class="pass">pass</span> <br>';}
																									else{echo "Weight     : ".$srv_value['weight'].' - <span class="meh">fail - doesn&#39;t really matter</span><br> <br>';}										
											if ($srv_value['port'] == "443")							{echo "Port       : ".$srv_value['port'].' - <span class="pass">pass</span> <br>';}	
																									else{echo "Port       : ".$srv_value['port'].' - <span class="fail">fail</span><br> <br>';}								
											if ($srv_value['target'] == "client.ukfastexchange.co.uk")	{echo "Target     : ".$srv_value['target'].' - <span class="pass">pass</span> <br>';}
																									else{echo "Target     : ".$srv_value['target'].' - <span class="fail">fail</span><br> <br>';}
											
											
										}
									
									}

									echo "<br />";
									echo "<br />";
									
									
									
									//SPF									
									$spf_result = dns_get_record($domain, DNS_TXT);									
									echo "<br />";
									echo "<h3>SPF (TXT) record</h3>";
									echo "<br />";													
										
									if (empty($spf_result)) {
										echo 'No SPF(TXT) Record - <span class="fail">fail</span><br>';
									}
									else{
										foreach($spf_result as $spf_key=>$spf_value){
										if (strpos($spf_value['txt'], 'include:_spf.ukfastexchange.co.uk') !== false)	{echo "SPF       : ".$spf_value['txt'].' - <span class="pass">pass</span> <br>';}
										}
									}	
									
									
									
									
									
								}
								?>
								
								
								
								
							</article>

					</div>

				<!-- Footer -->
					<div id="footer">
						<ul class="copyright">
							<li>&copy; hydramail.net</li><li>Design: <a href="http://html5up.net">HTML5 UP</a></li>
						</ul>
					</div>

			</div>


		
		
		
			<script src="assets/js/jquery.min.js"></script>
			<script src="assets/js/skel.min.js"></script>
			<script src="assets/js/skel-viewport.min.js"></script>
			<script src="assets/js/util.js"></script>
			<!--[if lte IE 8]><script src="assets/js/ie/respond.min.js"></script><![endif]-->
			<script src="assets/js/main.js"></script>


	</body>
</html>
