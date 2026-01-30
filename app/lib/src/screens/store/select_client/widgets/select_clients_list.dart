import 'package:app/src/widgets/card/select_client_card.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class SelectClientsList extends StatelessWidget {
  final List<Client?>? clients;
  final bool isFamily;
  final Function(Client?, bool)? onClientSelected;

  const SelectClientsList({
    Key? key,
    this.clients,
    this.isFamily = false,
    this.onClientSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // in iOS default scroll behaviour is BouncingScrollPhysics
      // in android its ClampingScrollPhysics Setting
      //ClampingScrollPhysics explicitly for both
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 100),
      itemCount: clients!.length,
      itemBuilder: (BuildContext context, int index) {
        return SelectClientCard(
          effectiveIndex: index % 7,
          client: clients![index],
          isFamily: isFamily,
          onClientSelected: onClientSelected,
        );
      },
    );
  }
}
