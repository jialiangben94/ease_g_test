import 'package:ease/src/util/function.dart';

var tncTitle = getLocale(
    "To proceed, please go through the following statements with your customer and obtain their acknowledgement");

var privacyStatement = """ 
  <h2 style="color:#FF007885" > ${getLocale("Privacy Statement")}</h2>
  <p>${getLocale("Collection and Processing of Personal Data. I authorize and give my consent to ETIQA Malaysia to collect, store, transmit, use, distribute, disclose, share, retain, dispose, destroy, and process my Personal Data which includes Personal Information and/or Sensitive Personal Information and Privileged Information contained in my customer record that I have answered electronically for any of the following purposes prescribed by the Data Privacy Act of 2012 and its Implementing Rules and Regulations")}: </p>
  <br> 
  <h3 style="color:#000000"> ${getLocale("Security Measures")} </h3>
  <p> ${getLocale("I understand that any information provided to ETIQA Malaysia is protected. ETIQA Malaysia will only collect my Personal Data through secure means and shall ensure confidentiality and privacy in all aspects of processing of my personal data")}. </p>
  <br>
  <h3 style="color:#000000"> ${getLocale("Retention and Destruction")} </h3>
  <p> ${getLocale("I understand that this authorization/consent shall continue to be in effect throughout the duration of my  insurance policy and/or until expiration of the records retention limit set by ETIQA Malaysia and/or relevant laws and regulations and the period set until destruction and/or disposal of my records, unless earlier withdrawn in writing.  I have read this form, understood its contents and consent to the processing of my personal data and be bound by all the terms and conditions stated above. I understand that my consent does not preclude the existence of other criteria for lawful processing of personal data, and does not waive any of my rights under the Data Privacy Act of 2012 and other applicable laws")}.</p>
  """;

var tncStatement = """ 
  <h2><strong><span style="color: rgb(0, 120, 133);">${getLocale("Terms and Conditions Statement")}</span>&nbsp;</strong></h2>
<p style="color:#000000"><strong>A. ${getLocale("Definition of Terms")}</strong></p>
<p>&nbsp;${getLocale("As used herein, unless otherwise specified")}:</p>
<p><strong style="color:#000000">&nbsp;&ldquo;${getLocale("Content")}/s&rdquo;</strong> ${getLocale("means information such as texts, computations, images, programs, computer codes, and other information")}&nbsp;</p>
<p><strong style="color:#000000">&ldquo;${getLocale("Plan Holder")}&rdquo;</strong> ${getLocale("shall mean the legal entity to which the Plan Members are")}&nbsp;</p>
<p><strong style="color:#000000">&ldquo;Etiqa&rdquo;</strong> ${getLocale("shall mean Etiqa Life and General Assurance Malaysia")}&nbsp;</p>
<p><strong style="color:#000000">&ldquo;${getLocale("Mobile device")}&rdquo;</strong> ${getLocale("shall refer to any electronic device such as, but not, at the moment, limited to, smart phones used by the Financial Advisers in downloading EaSE")}&nbsp;</p>
<p><strong style="color:#000000">B. ${getLocale("Grant of License and Applicability of EaSE Terms and Conditions")}&nbsp;</strong></p>
<p>${getLocale("The purpose of the application is a better appreciation of financial priorities. E will not force its clients to purchase the plan, nor will the data encoded in the application be migrated to another. You may be asked to provide us your financial information and you are responsible for ensuring the accuracy of this information. Majority of the functions would be handled, presented, encoded, by the Financial Adviser, and projections and results would be shown to the client")}.</p>
  """;

var termsOfUse = """ 
<div><span style=" font-size: 16; color: #000000;">${getLocale("Please read this information carefully. Access to this site is a confirmation that you, as a user of this site, understand and agree to be bound by all of these Terms of Use. The information made available on site is subject to change without notice")}.</span></div>
<div>&nbsp;</div>
<h2><span style="color: #FF007885;">1&nbsp;&nbsp;&nbsp; ${getLocale("Information Security")}</span></h2>
<div>&nbsp;</div>
<div><span style="color: #000000;"><strong><span style=" font-size: 16;">1.1&nbsp;&nbsp;&nbsp; ${getLocale("Data Confidentiality and Data Integrity")}</span></strong></span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("To ensure data confidentiality and data integrity, sensitive information (e.g. e-signatures) are encrypted with industrial-strength cryptography")}.</span></div>
<div>&nbsp;</div>
<div><span style="color: #000000;"><strong><span style=" font-size: 16;">1.2&nbsp;&nbsp;&nbsp; ${getLocale("Access to Customer BM")}${getLocale("&rsquo;s")} ${getLocale("Information BM")}</span></strong></span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("You are required to be aware of the privacy policy/ data privacy declaration of the customers and your confidentiality obligations, as well as to know how to handle customers' information in line with Etiqa Life Insurance Berhad")}${getLocale("&rsquo;s")} ('ETIQA') ${getLocale("privacy and information confidentiality principles")}.</span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("At all times, your access to this site shall be in compliance with the guidelines and directions of ETIQA, any law, regulations, or legislation, as may be applicable")}.</span></div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("You agree that you shall not abuse or misuse this site or the services herein. You shall always keep your username and password safe")}.</span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("You shall not at any time")}:</span></div>
<ol style="list-style-type: lower-roman;">
<li><span style=" font-size: 16; color: #000000;">${getLocale("Disclose any information obtained pursuant to ETIQA activating your account in this site to a third party")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Assist any other person to hack into or obtain unauthorized access to this site or any services herein")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Share your username and password with any third party; or")}</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Interfere with the access and use of the same by others")}.</span></li>
</ol>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("Furthermore, you shall not carry out nor assist any other person to transmit communication, information, or materials which")}:</span></div>
<ol style="list-style-type: lower-roman;">
<li><span style=" font-size: 16; color: #000000;">${getLocale("Adversely affect our rights or the rights of others")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Which is morally offensive")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Which adversely affects our internet insurance system or the security of our internet insurance system; or")}</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Which is otherwise against the law")}.</span></li>
</ol>
<div><span style=" font-size: 16; color: #000000;">&nbsp;</span></div>
<h2><span style=" color: #FF007885;">2&nbsp;&nbsp;&nbsp; ${getLocale("Data Privacy Declaration")}</span></h2>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("The term 'Personal Data' used in this clause shall have the meaning set out in Section 4 of the Personal Data Protection Act 2010")} (&ldquo;PDPA&rdquo;).&nbsp;</span><span style=" font-size: 16; color: #000000;">At all times, your access to this site shall be in compliance with the guidelines and directions of ETIQA, any law, regulations, or legislation, as may be applicable.</span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("You understand, agree, and give your consent to ETIQA (and any third party appointed by ETIQA on ETIQA's behalf) to collect, hold, use, delete, disclose, transfer, and process in any other way, all your Personal Data, whether given now or subsequently to ETIQA from time to time, for the purposes of")}:</span></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("Processing any application to ETIQA to register for or to activate a user account for this site, whether made now or subsequently")};</span></div>
<ol style="list-style-type: lower-roman;">
<li><span style=" font-size: 16; color: #000000;">${getLocale("Researching and auditing, including but not limited to historical and statistical data")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Exercising any right of subrogation")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Updating ETIQA's records")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Data matching")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Detection and prevention of fraud")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Carrying out any activity in relation to or in connection with carrying out ETIQA's duties as an insurer or principal of its agents (if applicable) or a data user under the PDPA")};</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Communicating with you for any of these purposes; and")}</span></li>
<li><span style=" font-size: 16; color: #000000;">${getLocale("Allowing ETIQA to evaluate the effectiveness of the use of this site and for statistical analysis")}.</span></li>
</ol>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("To achieve the purposes set out in clause 2(b) above, you give your consent to ETIQA to transfer and share your Personal Data to individuals or organizations within ETIQA's and Maybank Ageas Holdings Berhad group of companies/affiliates or other third parties including the relevant authorities and other third-party service providers ETIQA has appointed (that provide administrative, telecommunications, payment, data processing, data storage, or other services to ETIQA) in connection with purposes set out in clause 2(b) above. As some of these third parties are not located in Malaysia, ETIQA may transfer your Personal Data to places outside of Malaysia")}.</span></div>
<div><span style=" font-size: 16; color: #000000;">&nbsp;</span></div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("All consent relating to your Personal Data here shall also apply to Personal Data relating to your religious beliefs or other beliefs of a similar nature, physical or mental health, or medical condition, which would be necessary for or directly related to the purposes set out in clause 2(b) above")}.</span></div>
<div><span style=" font-size: 16; color: #000000;">&nbsp;</span></div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("You have the right to see the Personal Data ETIQA holds about you, and to have it corrected if it is wrong")}.</span></div>
<div><span style=" font-size: 16; color: #000000;">&nbsp;</span></div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("In the event where the Personal Data given now to or that is subsequently obtained by ETIQA from time to time by you is not your Personal Data but that of another individual ('the Data Subject'), you confirm that you have informed the Data Subject that you are providing the Data Subject's Personal Data to ETIQA, and have obtained the Data Subject's consent to do so. You further confirm that you have explained the contents of this Data Privacy Declaration to the Data Subject and that he/she understands, agrees, and authorizes ETIQA to deal with such Personal Data according to what is stated in this declaration")}.</span></div>
<div><span style=" font-size: 16; color: #000000;">&nbsp;</span></div>
<div><h2><strong><span style="color: #FF007885;">3&nbsp;&nbsp;&nbsp; ${getLocale("Undertaking and Indemnity")}</span></strong><h2></div>
<div>&nbsp;</div>
<div><span style=" font-size: 16; color: #000000;">${getLocale("In consideration of ETIQA activating your account on this site, you irrevocably agree that you shall at all times keep ETIQA harmless, discharged, and fully indemnified against all actions, claims, costs (including all legal costs on solicitor and client basis), damages (including any damages or compensation paid by ETIQA on the advice of its legal advisers to compromise or settle any such claim), demands, expenses, fines, losses, penalties, proceedings, that any of them may incur or suffer by any reason howsoever arising from or incidental to ETIQA activating, rejecting, closing, removing or suspending your account in this site. This clause shall be binding upon your respective successors in title, executors, administrators, personal representatives, and/or heirs. This clause shall survive the closure, removal, or suspension of your account on this site")}.</span></div>
<div>&nbsp;</div>
""";
