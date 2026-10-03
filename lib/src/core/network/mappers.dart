import 'package:storryca/src/core/constants/images.const.dart';
import 'package:storryca/src/core/network/image_url.dart';
import 'package:storryca/src/core/network/models/author_api_model.dart';
import 'package:storryca/src/core/network/models/chapter_api_model.dart';
import 'package:storryca/src/core/network/models/story_api_model.dart';
import 'package:storryca/src/features/discover/types/story_item.typres.dart';
import 'package:storryca/src/features/home/presentation/types/author.types.dart';
import 'package:storryca/src/features/story/types/story_chapter_type.dart';

StoryItemTypes storyItemFromApi(StoryApiModel story) => StoryItemTypes(
  id: story.id,
  title: story.title,
  image: coverUrl(story.cover, fallbackAsset: noStoryIMG),
  reads: (story.periodReads ?? story.reads).toDouble(),
  comments: 0,
  rating: story.ratings.round(),
  ratingCount: 0,
  category: story.genre,
  currentChapter: 0,
  totalChapter: story.chapters,
  progress: 0,
  isSaved: false,
  author: story.authorName,
  description: story.summary,
  likes: story.likes.toString(),
  views: story.views.toString(),
  status: story.state,
);

AuthorTypes authorFromApi(AuthorApiModel author) => AuthorTypes(
  id: author.id,
  image: avatarUrl(author.image),
  name: author.name,
  stories: author.publishedStories,
  description: author.aboutMe,
  category: '',
  followers: author.followers,
  rating: 0,
);

StoryChapterType chapterFromApi(ChapterApiModel chapter) => StoryChapterType(
  index: chapter.orderIndex,
  name: chapter.title,
  date: '',
  views: '-',
  isCurrent: false,
  words: chapter.wordCount.toString(),
  status: chapter.status,
);
