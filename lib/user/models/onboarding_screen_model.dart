import '../constants/app_strings.dart';
import '../constants/images_url.dart';

class OnboardingModel {
  String title;
  String subTitle;
  String imageUrl;

  OnboardingModel({
    required this.title,
    required this.subTitle,
    required this.imageUrl,
  });
}

List<OnboardingModel> onBoardingItems = [
  OnboardingModel(
    title: AppStrings.onboardingTitle1,
    subTitle: AppStrings.onboardingSubTitle1,
    imageUrl: ImageUrls.cart,
  ),
  OnboardingModel(
    title: AppStrings.onboardingTitle2,
    subTitle: AppStrings.onboardingSubTitle2,
    imageUrl: ImageUrls.shopping,
  ),
  OnboardingModel(
    title: AppStrings.onboardingTitle3,
    subTitle: AppStrings.onboardingSubTitle3,
    imageUrl: ImageUrls.delivery,
  ),
];
