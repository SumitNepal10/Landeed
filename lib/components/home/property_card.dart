import 'package:flutter/material.dart';
import 'package:partice_project/components/gap.dart';
import 'package:partice_project/constant/colors.dart';

class PropertyCard extends StatelessWidget {
  final String title, subtitle, path;
  final bool isBig;
  const PropertyCard(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.path,
      this.isBig = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 1;
    return Container(
      width: isBig ? width / 1 : width / 1.35,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          image: DecorationImage(
              image: AssetImage(path),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.darken))),
      child: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22, bottom: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(isWidth: false, isHeight: true, height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: AppColors.whiteColor, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(isWidth: false, isHeight: true, height: 12),
            InkWell(
              onTap: () {
                print("cool");
              },
              child: Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    "View",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: AppColors.whiteColor),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
