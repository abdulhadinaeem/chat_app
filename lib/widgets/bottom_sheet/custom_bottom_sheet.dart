import 'package:chat_app/core/constant/app_images.dart';
import 'package:chat_app/view_model/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomSheet extends StatelessWidget {
  CustomBottomSheet(
      {super.key, required this.reciverId, required this.reciverToken});
  final String? reciverId;
  final String? reciverToken;
  final provider = ChatViewModel();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              bottomSheetIcons(
                color: Colors.purple,
                image: AppImages.documentIcon,
                title: 'Document',
                onTap: () {},
              ),
              bottomSheetIcons(
                color: Colors.red,
                image: AppImages.cameraIcon,
                title: 'Camera',
                onTap: () {
                  provider.getImagesFromCamera().then((value) {
                    provider.sendImageMessage(
                        reciverId ?? "", reciverToken ?? '');
                    Navigator.pop(context);
                  });
                },
              ),
              bottomSheetIcons(
                color: Colors.blue,
                image: AppImages.galleryIcon,
                title: 'Gallery',
                onTap: () {
                  provider.getImages().then((value) {
                    provider.sendImageMessage(
                        reciverId ?? "", reciverToken ?? '');
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              bottomSheetIcons(
                color: Colors.indigoAccent,
                image: AppImages.audioIcon,
                title: 'Audio',
                height: 27,
                onTap: () {},
              ),
              bottomSheetIcons(
                color: Colors.green,
                image: AppImages.personIcon,
                title: 'Contact',
                height: 27,
                onTap: () {},
              ),
              bottomSheetIcons(
                color: Colors.orange,
                image: AppImages.locationIcon,
                title: 'Location',
                height: 27,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class bottomSheetIcons extends StatelessWidget {
  bottomSheetIcons(
      {super.key,
      required this.color,
      required this.image,
      required this.title,
      this.height,
      required this.onTap});
  String image;
  String title;
  Color color;
  double? height;
  void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Center(
              child: SvgPicture.asset(
                image,
                color: Colors.white,
                height: height,
              ),
            ),
          ),
        ),
        Text(title),
      ],
    );
  }
}
