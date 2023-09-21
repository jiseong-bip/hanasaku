import 'package:flutter/material.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: const Column(
            children: [
              Text(
                'Terms and conditions',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: Sizes.size16),
              ),
              Gaps.v10,
              Text(
                  'These terms and conditions (“Agreement”) set forth the general terms and conditions of your use of the “HANASAKU” mobile application (“Mobile Application” or “Service”) and any of its related products and services (collectively, “Services”). This Agreement is legally binding between you (“User”, “you” or “your”) and this Mobile Application developer (“Operator”, “we”, “us” or “our”). If you are entering into this Agreement on behalf of a business or other legal entity, you represent that you have the authority to bind such entity to this Agreement, in which case the terms “User”, “you” or “your” shall refer to such entity. If you do not have such authority, or if you do not agree with the terms of this Agreement, you must not accept this Agreement and may not access and use the Mobile Application and Services. By accessing and using the Mobile Application and Services, you acknowledge that you have read, understood, and agree to be bound by the terms of this Agreement. You acknowledge that this Agreement is a contract between you and the Operator, even though it is electronic and is not physically signed by you, and it governs your use of the Mobile Application and Services.'),
              Gaps.v10,
              Text('Accounts and membership',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'You must be at least 16 years of age to use the Mobile Application and Services. By using the Mobile Application and Services and by agreeing to this Agreement you warrant and represent that you are at least 16 years of age.If you create an account in the Mobile Application, you are responsible for maintaining the security of your account and you are fully responsible for all activities that occur under the account and any other actions taken in connection with it. We may monitor and review new accounts before you may sign in and start using the Services. Providing false contact information of any kind may result in the termination of your account. You must immediately notify us of any unauthorized uses of your account or any other breaches of security. We will not be liable for any acts or omissions by you, including any damages of any kind incurred as a result of such acts or omissions. We may suspend, disable, or delete your account (or any part thereof) if we determine that you have violated any provision of this Agreement or that your conduct or content would tend to damage our reputation and goodwill. If we delete your account for the foregoing reasons, you may not re-register for our Services. We may block your email address and Internet protocol address to prevent further registration.'),
              Gaps.v10,
              Text('User content',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We do not own any data, information or material (collectively, “Content”) that you submit in the Mobile Application in the course of using the Service. You shall have sole responsibility for the accuracy, quality, integrity, legality, reliability, appropriateness, and intellectual property ownership or right to use of all submitted Content. We may monitor and review the Content in the Mobile Application submitted or created using our Services by you. You grant us permission to access, copy, distribute, store, transmit, reformat, display and perform the Content of your user account solely as required for the purpose of providing the Services to you. Without limiting any of those representations or warranties, we have the right, though not the obligation, to, in our own sole discretion, refuse or remove any Content that, in our reasonable opinion, violates any of our policies or is in any way harmful or objectionable. You also grant us the license to use, reproduce, adapt, modify, publish or distribute the Content created by you or stored in your user account for commercial, marketing or any similar purpose.'),
              Gaps.v10,
              Text('Backups',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We are not responsible for the Content residing in the Mobile Application. In no event shall we be held liable for any loss of any Content. It is your sole responsibility to maintain appropriate backup of your Content. Notwithstanding the foregoing, on some occasions and in certain circumstances, with absolutely no obligation, we may be able to restore some or all of your data that has been deleted as of a certain date and time when we may have backed up data for our own purposes. We make no guarantee that the data you need will be available.'),
              Gaps.v10,
              Text('Links to other resources',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'Although the Mobile Application and Services may link to other resources (such as websites, mobile applications, etc.), we are not, directly or indirectly, implying any approval, association, sponsorship, endorsement, or affiliation with any linked resource, unless specifically stated herein. We are not responsible for examining or evaluating, and we do not warrant the offerings of, any businesses or individuals or the content of their resources. We do not assume any responsibility or liability for the actions, products, services, and content of any other third parties. You should carefully review the legal statements and other conditions of use of any resource which you access through a link in the Mobile Application. Your linking to any other off-site resources is at your own risk.'),
              Gaps.v10,
              Text('Prohibited uses',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'In addition to other terms as set forth in the Agreement, you are prohibited from using the Mobile Application and Services or Content: (a) for any unlawful purpose; (b) to solicit others to perform or participate in any unlawful acts; (c) to violate any international, federal, provincial or state regulations, rules, laws, or local ordinances; (d) to infringe upon or violate our intellectual property rights or the intellectual property rights of others; (e) to harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate based on gender, sexual orientation, religion, ethnicity, race, age, national origin, or disability; (f) to submit false or misleading information; (g) to upload or transmit viruses or any other type of malicious code that will or may be used in any way that will affect the functionality or operation of the Mobile Application and Services, third party products and services, or the Internet; (h) to spam, phish, pharm, pretext, spider, crawl, or scrape; (i) for any obscene or immoral purpose; or (j) to interfere with or circumvent the security features of the Mobile Application and Services, third party products and services, or the Internet. We reserve the right to terminate your use of the Mobile Application and Services for violating any of the prohibited uses.'),
              Gaps.v10,
              Text('Dispute resolution',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Text(
                  'The formation, interpretation, and performance of this Agreement and any disputes arising out of it shall be governed by the substantive and procedural laws of Tokyo, Japan without regard to its rules on conflicts or choice of law and, to the extent applicable, the laws of Japan. The exclusive jurisdiction and venue for actions related to the subject matter hereof shall be the courts located in Tokyo, Japan, and you hereby submit to the personal jurisdiction of such courts. You hereby waive any right to a jury trial in any proceeding arising out of or related to this Agreement. The United Nations Convention on Contracts for the International Sale of Goods does not apply to this Agreement.'),
              Gaps.v10,
              Text('Changes and amendments',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'We reserve the right to modify this Agreement or its terms related to the Mobile Application and Services at any time at our discretion. When we do, we will post a notification in the Mobile Application. We may also provide notice to you in other ways at our discretion, such as through the contact information you have provided.An updated version of this Agreement will be effective immediately upon the posting of the revised Agreement unless otherwise specified. Your continued use of the Mobile Application and Services after the effective date of the revised Agreement (or such other act specified at that time) will constitute your consent to those changes.'),
              Gaps.v10,
              Text('Acceptance of these terms',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'You acknowledge that you have read this Agreement and agree to all its terms and conditions. By accessing and using the Mobile Application and Services you agree to be bound by this Agreement. If you do not agree to abide by the terms of this Agreement, you are not authorized to access or use the Mobile Application and Services. This terms and conditions policy was created with the help of https://www.websitepolicies.com/terms-and-conditions-generator'),
              Gaps.v10,
              Text('Contacting us',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Sizes.size16)),
              Gaps.v10,
              Text(
                  'If you have any questions, concerns, or complaints regarding this Agreement, we encourage you to contact us using the details below: hanasaku230812@gmail.com This document was last updated on September 19, 2023')
            ],
          ),
        ),
      ),
    );
  }
}
