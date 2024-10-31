class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Create and review your Flashcards",
    image: "assets/flash-card.png",
    desc: "Create as much flashcards and have your recall practiced.",
  ),
  OnboardingContents(
    title: "Test Yourself",
    image: "assets/study.png",
    desc:
        "Test your recalls with time limits",
  ),
  OnboardingContents(
    title: "Export your flashcards",
    image: "assets/export.svg",
    desc:
        "Export or import your flashcards from anywhere.",
  ),
];