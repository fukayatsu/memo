---
tags: dev
---

# memo.fukayatsu.com の実装を始めた

ここ数年仕事以外では文章をあまりoutputできていなかったが、そろそろまたblog的なものを再開したいと思い、 `memo.fukayatsu.com` の実装を始めた。

# 実装方針

- 静的サイトジェネレータをRubyで実装する
  - ~~`bundle install` せずに動くようにする~~
    - と思ったが、Markdownパーサを書く気にはなれなかったので、必要最低限のGemを使うことにする
  - ローカルでbuildせずにプレビューできるようにする
- GitHub ActionsでbuildしてGitHub Pages で配信

# 所感

- 抱っこ紐の中で子が暴れており、そろそろ限界
