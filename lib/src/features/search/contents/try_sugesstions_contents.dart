import 'package:remixicon/remixicon.dart';
import 'package:storryca/src/features/search/types/try_suggestion_type.dart';

List<TrySuggestionType> suggestions = [
  TrySuggestionType(
    title: 'Check the Spelling',
    caption: 'Make sure all words are spelled correctly.',
    icon: Remix.search_ai_2_line,
  ),
  TrySuggestionType(
    title: 'Use fewer or different keywords',
    caption: 'Try more general words or different phrases.',
    icon: Remix.compass_3_line,
  ),
  TrySuggestionType(
    title: 'Explore trending searches',
    caption: 'See what others are reading right now.',
    icon: Remix.fire_line,
  ),
  TrySuggestionType(
    title: 'Explore Genres',
    caption: 'Find stories by genre, mood, or theme.',
    icon: Remix.layout_grid_fill,
  ),
];
