import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class ServiceRequestConfirmation extends StatefulWidget {
  // Fields
  final String serviceRequestUrl;
  final Client client;
  final Function onClick;
  final String type;

  const ServiceRequestConfirmation({
    Key? key,
    required this.serviceRequestUrl,
    required this.client,
    required this.onClick,
    required this.type,
  }) : super(key: key);

  @override
  _ServiceRequestConfirmationState createState() =>
      _ServiceRequestConfirmationState();
}

class _ServiceRequestConfirmationState extends State<ServiceRequestConfirmation>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    _lottieController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Center(
            child: Container(
              width: 72,
              height: 72,
              child: Lottie.asset(
                AllImages().verifiedIconLottie,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'Service request has been raised succesfully! to update the ${widget.type} details',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: ColorConstants.black,
                ),
          ),
          // An approval request has been sent to the client via email
          // at sid17mewada@gmail.com and through WhatsApp
          // at 9167849010. Once the changes are approved, they will be promptly updated.
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 30,
            ),
            child: Center(
              child: Text.rich(
                TextSpan(
                  text:
                      'An approval request has been sent to the client ${widget.client.email.isNotNullOrEmpty ? "via email at" : ""}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                  children: [
                    if (widget.client.email.isNotNullOrEmpty)
                      TextSpan(
                        text: ' ${widget.client.email}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    if (widget.client.email.isNotNullOrEmpty &&
                        widget.client.phoneNumber.isNotNullOrEmpty)
                      TextSpan(
                        text: ' and ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    if (widget.client.phoneNumber.isNotNullOrEmpty)
                      TextSpan(
                        text: ' through WhatsApp at ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    if (widget.client.phoneNumber.isNotNullOrEmpty)
                      TextSpan(
                        text: '${widget.client.phoneNumber}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    TextSpan(
                      text:
                          '. Once the changes are approved, they will be promptly updated.',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: ColorConstants.primaryCardColor,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Contact client to speed up\nthe confirmation ?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40, right: 40.0, bottom: 24.0, top: 16.0),
                  child: Text(
                    'Let ${widget.client.name ?? 'Client'} know that you have raised the service request.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                            fontSize: 12,
                            color: ColorConstants.tertiaryGrey,
                            height: 1.4),
                  ),
                ),
                if (widget.client.phoneNumber.isNotNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28)
                        .copyWith(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            await launch('tel:${widget.client.phoneNumber}');
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AllImages().callRoundedIcon,
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                'Call Now',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final link = WhatsAppUnilink(
                                phoneNumber: widget.client.phoneNumber,
                                text:
                                    "Hey ${widget.client.name ?? 'there'}, here is the created ${widget.type} Service Request for you ${widget.serviceRequestUrl}. Please approve this request so that changes get updated.");

                            await launch('$link');
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AllImages().whatsappRoundedIcon,
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(
                                'Whatsapp',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                Divider(
                  color: ColorConstants.lightGrey,
                ),
                ActionButton(
                  text: 'Got it',
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                  onPressed: () {
                    widget.onClick();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
