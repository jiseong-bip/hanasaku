import 'package:flutter/material.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Privacy policy',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We respect your privacy and are committed to protecting it through our compliance with this privacy policy (“Policy”). This Policy describes the types of information we may collect from you or that you may provide (“Personal Information”) in the “HANASAKU” mobile application (“Mobile Application” or “Service”) and any of its related products and services (collectively, “Services”), and our practices for collecting, using, maintaining, protecting, and disclosing that Personal Information. It also describes the choices available to you regarding our use of your Personal Information and how you can access and update it.This Policy is a legally binding agreement between you (“User”, “you” or “your”) and this Mobile Application developer (“Operator”, “we”, “us” or “our”). If you are entering into this Policy on behalf of a business or other legal entity, you represent that you have the authority to bind such entity to this Policy, in which case the terms “User”, “you” or “your” shall refer to such entity. If you do not have such authority, or if you do not agree with the terms of this Policy, you must not accept this Policy and may not access and use the Mobile Application and Services. By accessing and using the Mobile Application and Services, you acknowledge that you have read, understood, and agree to be bound by the terms of this Policy. This Policy does not apply to the practices of companies that we do not own or control, or to individuals that we do not employ or manage.'),
              Gaps.v10,
              Text('Collection of personal information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'You can access and use the Mobile Application and Services without telling us who you are or revealing any information by which someone could identify you as a specific, identifiable individual. If, however, you wish to use some of the features offered in the Mobile Application, you may be asked to provide certain Personal Information (for example, your name and e-mail address).We receive and store any information you knowingly provide to us when you create an account, publish content, or fill any forms in the Mobile Application. When required, this information may include the following: Account details (such as user name, unique user ID, password, etc) Contact information (such as email address, phone number, etc)Certain features on the mobile device (such as contacts, calendar, gallery, etc)You can choose not to provide us with your Personal Information, but then you may not be able to take advantage of some of the features in the Mobile Application. Users who are uncertain about what information is mandatory are welcome to contact us.'),
              Gaps.v10,
              Text('Privacy of children',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We do not knowingly collect any Personal Information from children under the age of 13. If you are under the age of 13, please do not submit any Personal Information through the Mobile Application and Services. If you have reason to believe that a child under the age of 13 has provided Personal Information to us through the Mobile Application and Services, please contact us to request that we delete that child’s Personal Information from our Services.We encourage parents and legal guardians to monitor their children’s Internet usage and to help enforce this Policy by instructing their children never to provide Personal Information through the Mobile Application and Services without their permission. We also ask that all parents and legal guardians overseeing the care of children take the necessary precautions to ensure that their children are instructed to never give out Personal Information when online without their permission.'),
              Gaps.v10,
              Text('Use and processing of collected information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We act as a data controller and a data processor when handling Personal Information, unless we have entered into a data processing agreement with you in which case you would be the data controller and we would be the data processor.Our role may also differ depending on the specific situation involving Personal Information. We act in the capacity of a data controller when we ask you to submit your Personal Information that is necessary to ensure your access and use of the Mobile Application and Services. In such instances, we are a data controller because we determine the purposes and means of the processing of Personal Information.We act in the capacity of a data processor in situations when you submit Personal Information through the Mobile Application and Services. We do not own, control, or make decisions about the submitted Personal Information, and such Personal Information is processed only in accordance with your instructions. In such instances, the User providing Personal Information acts as a data controller.In order to make the Mobile Application and Services available to you, or to meet a legal obligation, we may need to collect and use certain Personal Information. If you do not provide the information that we request, we may not be able to provide you with the requested products or services. Any of the information we collect from you may be used for the following purposes:\nCreate and manage user accounts\nImprove user experience\nProtect from abuse and malicious users\nRun and operate the Mobile Application and Services\nProcessing your Personal Information depends on how you interact with the Mobile Application and Services, where you are located in the world and if one of the following applies: (i) you have given your consent for one or more specific purposes; (ii) provision of information is necessary for the performance of this Policy with you and/or for any pre-contractual obligations thereof; (iii) processing is necessary for compliance with a legal obligation to which you are subject; (iv) processing is related to a task that is carried out in the public interest or in the exercise of official authority vested in us; (v) processing is necessary for the purposes of the legitimate interests pursued by us or by a third party.\nNote that under some legislations we may be allowed to process information until you object to such processing by opting out, without having to rely on consent or any other of the legal bases. In any case, we will be happy to clarify the specific legal basis that applies to the processing, and in particular whether the provision of Personal Information is a statutory or contractual requirement, or a requirement necessary to enter into a contract.'),
              Gaps.v10,
              Text('Managing information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'You are able to delete certain Personal Information we have about you. The Personal Information you can delete may change as the Mobile Application and Services change. When you delete Personal Information, however, we may maintain a copy of the unrevised Personal Information in our records for the duration necessary to comply with our obligations to our affiliates and partners, and for the purposes described below. If you would like to delete your Personal Information or permanently delete your account, you can do so on the settings page of your account in the Mobile Application.'),
              Text('Disclosure of information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'Depending on the requested Services or as necessary to complete any transaction or provide any Service you have requested, we may share your information with our affiliates, contracted companies, and service providers (collectively, “Service Providers”) we rely upon to assist in the operation of the Mobile Application and Services available to you and whose privacy policies are consistent with ours or who agree to abide by our policies with respect to Personal Information. We will not share any personally identifiable information with third parties and will not share any information with unaffiliated third parties.Service Providers are not authorized to use or disclose your information except as necessary to perform services on our behalf or comply with legal requirements. Service Providers are given the information they need only in order to perform their designated functions, and we do not authorize them to use or disclose any of the provided information for their own marketing or other purposes.'),
              Gaps.v10,
              Text('Retention of information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We will retain and use your Personal Information for the period necessary as long as your user account remains active, to enforce our Policy, resolve disputes, and unless a longer retention period is required or permitted by law.We may use any aggregated data derived from or incorporating your Personal Information after you update or delete it, but not in a manner that would identify you personally. Once the retention period expires, Personal Information shall be deleted. Therefore, the right to access, the right to erasure, the right to rectification, and the right to data portability cannot be enforced after the expiration of the retention period.'),
              Gaps.v10,
              Text('Social media features',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'Our Mobile Application and Services may include social media features, such as the Facebook and Twitter buttons, Share This buttons, etc (collectively, “Social Media Features”). These Social Media Features may collect your IP address, what page you are visiting on our Mobile Application and Services, and may set a cookie to enable Social Media Features to function properly. Social Media Features are hosted either by their respective providers or directly on our Mobile Application and Services. Your interactions with these Social Media Features are governed by the privacy policy of their respective providers.'),
              Gaps.v10,
              Text('Push notifications',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We offer push notifications to which you may voluntarily subscribe at any time. To make sure push notifications reach the correct devices, we use a third-party push notifications provider who relies on a device token unique to your device which is issued by the operating system of your device. While it is possible to access a list of device tokens, they will not reveal your identity, your unique device ID, or your contact information to us or our third-party push notifications provider. We will maintain the information sent via e-mail in accordance with applicable laws and regulations. If, at any time, you wish to stop receiving push notifications, simply adjust your device settings accordingly.'),
              Gaps.v10,
              Text('Links to other resources',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'The Mobile Application and Services contain links to other resources that are not owned or controlled by us. Please be aware that we are not responsible for the privacy practices of such other resources or third parties. We encourage you to be aware when you leave the Mobile Application and Services and to read the privacy statements of each and every resource that may collect Personal Information.'),
              Gaps.v10,
              Text('Information security',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We secure information you provide on computer servers in a controlled, secure environment, protected from unauthorized access, use, or disclosure. We maintain reasonable administrative, technical, and physical safeguards in an effort to protect against unauthorized access, use, modification, and disclosure of Personal Information in our control and custody. However, no data transmission over the Internet or wireless network can be guaranteed.Therefore, while we strive to protect your Personal Information, you acknowledge that (i) there are security and privacy limitations of the Internet which are beyond our control; (ii) the security, integrity, and privacy of any and all information and data exchanged between you and the Mobile Application and Services cannot be guaranteed; and (iii) any such information and data may be viewed or tampered with in transit by a third party, despite best efforts.As the security of Personal Information depends in part on the security of the device you use to communicate with us and the security you use to protect your credentials, please take appropriate measures to protect this information.'),
              Gaps.v10,
              Text('Data breach',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'In the event we become aware that the security of the Mobile Application and Services has been compromised or Users’ Personal Information has been disclosed to unrelated third parties as a result of external activity, including, but not limited to, security attacks or fraud, we reserve the right to take reasonably appropriate measures, including, but not limited to, investigation and reporting, as well as notification to and cooperation with law enforcement authorities. In the event of a data breach, we will make reasonable efforts to notify affected individuals if we believe that there is a reasonable risk of harm to the User as a result of the breach or if notice is otherwise required by law. When we do, we will send you an email.'),
              Gaps.v10,
              Text('Changes and amendments',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We reserve the right to modify this Policy or its terms related to the Mobile Application and Services at any time at our discretion. When we do, we will post a notification in the Mobile Application. We may also provide notice to you in other ways at our discretion, such as through the contact information you have provided.An updated version of this Policy will be effective immediately upon the posting of the revised Policy unless otherwise specified. Your continued use of the Mobile Application and Services after the effective date of the revised Policy (or such other act specified at that time) will constitute your consent to those changes. However, we will not, without your consent, use your Personal Information in a manner materially different than what was stated at the time your Personal Information was collected.'),
              Gaps.v10,
              Text('Acceptance of this policy',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'ou acknowledge that you have read this Policy and agree to all its terms and conditions. By accessing and using the Mobile Application and Services and submitting your information you agree to be bound by this Policy. If you do not agree to abide by the terms of this Policy, you are not authorized to access or use the Mobile Application and Services. This privacy policy was created with the help of https://www.websitepolicies.com/privacy-policy-generator'),
              Gaps.v10,
              Text('Contacting us',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'If you have any questions, concerns, or complaints regarding this Policy, the information we hold about you, or if you wish to exercise your rights, we encourage you to contact us using the details below: \nhanasaku230812@gmail.com\nWe will attempt to resolve complaints and disputes and make every reasonable effort to honor your wish to exercise your rights as quickly as possible and in any event, within the timescales provided by applicable data protection laws.This document was last updated on September 19, 2023'),
            ],
          ),
        ),
      ),
    );
  }
}
