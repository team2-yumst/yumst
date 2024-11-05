## <i>Commit Message Convention</i>

## Commit Message Structure
- 기본적인 커밋 메시지 구조(각 파트는 빈줄로 구분)
> 제목 (Type: Subject)
> 
> (한줄 띄어 분리)
> 
> 본문 (Body)
> 
> (한줄 띄어 분리)
> 
> 꼬리말 (Footer)

## Commit Type
- 커밋의 타입 구성

> 태그: 제목
> 
> :(space)제목 으로 :뒤에만 space를 넣는다.

| Tag Name          | Description                                    |
|-------------------|------------------------------------------------|
| Feat              | 새로운 기능을 추가                              |
| Fix               | 버그 수정                                      |
| Design            | CSS 등 사용자 UI 디자인 변경                   |
| !BREAKING CHANGE  | 커다란 API 변경의 경우                         |
| !HOTFIX           | 급하게 치명적인 버그를 고쳐야하는 경우         |
| Style             | 코드 포맷 변경, 세미 콜론 누락, 코드 수정이 없는 경우 |
| Refactor          | 프로덕션 코드 리팩토링                          |
| Comment           | 필요한 주석 추가 및 변경                        |
| Docs              | 문서 수정                                      |
| Test              | 테스트 코드, 리팩토링 테스트 코드 추가, Production Code(실제로 사용하는 코드) 변경 없음 |
| Chore             | 빌드 업무 수정, 패키지 매니저 수정, 패키지 관리자 구성 등 업데이트, Production Code 변경 없음 |
| Rename            | 파일 혹은 폴더명을 수정하거나 옮기는 작업만인 경우 |
| Remove            | 파일을 삭제하는 작업만 수행한 경우             |

추가적인 문맥 정보 제공으로 괄호 안에 적을 수도 있음 ex) feat(navigation)

## Subject
- 제목은 50글자 이내로 작성한다.
- 첫글자는 대문자로 작성한다.
- 마침표 및 특수기호는 사용하지 않는다.
- 영문으로 작성하는 경우 동사(원형)을 가장 앞에 명령어로 작성한다.
- 과거시제는 사용하지 않는다.
- 간결하고 요점적으로 즉, 개조식 구문으로 작성한다.

> ex)
> Fixed --> Fix
> 
> Added --> Add
> 
> Modified --> Modify

## Body
- 72 이내로 작성한다
- 최대한 상세히 작성한다 (코드 변경 이유 명확히)
- 무엇을, 왜 변경했는지 작성한다

## Footer
- 선택사항
- issue tracker ID 명시하고 싶은 경우에 작성한다.
- 유형: #이슈 번호 형식으로 작성한다.
- 여러 개의 이슈번호는 쉼표(,)로 구분한다.
- 이슈 트래커 유형은 다음 중 하나를 사용한다.
  Fixes: 이슈 수정중 (아직 해결되지 않은 경우)
  Resolves: 이슈를 해결했을 때 사용
  Ref: 참고할 이슈가 있을 때 사용
  Related to: 해당 커밋에 관련된 이슈번호 (아직 해결되지 않은 경우)
> ex)
> 
> Fixes: #45 Related to: #34, #23

## Example
예시 1
```
Feat: 회원 가입 기능 구현

SMS, 이메일 중복확인 API 개발

Resolves: #123
Ref: #456
Related to: #48, #45
```
예시 2
```
feat: Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, preceded
by a single space, with blank lines in between, but conventions
vary here

If you use an issue tracker, put references to them at the bottom,
like this:

Resolves: #123
See also: #456, #789
```
그 외 자주 쓰이는
```
 Fix : 버그 수정
  Fix my test
  Fix typo in style.css
  Fix my test to return undefined
  Fix error when using my function

  Update : Fix와 달리 원래 정상적으로 동작했지만 보완의 개념
  Update harry-server.js to use HTTPS

  Add
  Add documentation for the defaultPort option
  Add example for setting Vary: Accept-Encoding header in zlib.md

  Remove(Clean이나 Eliminate) : ‘unnecessary’, ‘useless’, ‘unneeded’, ‘unused’, ‘duplicated’가 붙는 경우가 많음
  Remove fallback cache
  Remove unnecessary italics from child_process.md

  Refactor : 리팩토링

  Simplify : Refactor와 유사하지만 약한 수정, 코드 단순화

  Improve : 호환성, 테스트 커버리지, 성능, 검증 기능, 접근성 등의 향상
  Improve iOS's accessibilityLabel performance by up to 20%

  Implement : 코드 추가보다 큰 단위의 구현
  Implement bundle sync status

  Correct : 주로 문법의 오류나 타입의 변경, 이름 변경 등에 사용
  Correct grammatical error in BUILDING.md

  Prevent
  Prevent hello handler from saying Hi in hi.js

  Avoid : Prevent는 못하게 막지만, Avoid는 회피(if 등)
  Avoid flusing uninitialized traces

  Move : 코드나 파일의 이동
  Move function from header to source file

  Rename : 이름 변경
  Rename node-report to report
```

## 🏞 스크린샷 (선택)
> 스크린샷을 첨부해주세요.

## Commit Message Emoji(gitmoji)
| Emoji | Description |
|-------|-------------|
| 🎨    | 코드의 형식 / 구조를 개선 할 때 |
| 📰    | 새 파일을 만들 때 |
| 📝    | 사소한 코드 또는 언어를 변경할 때 |
| 🐎    | 성능을 향상시킬 때 |
| 📚    | 문서를 쓸 때 |
| 🐛    | 버그 reporting할 때, @FIXME 주석 태그 삽입 |
| 🚑    | 버그를 고칠 때 |
| 🐧    | 리눅스에서 무언가를 고칠 때 |
| 🍎    | Mac OS에서 무언가를 고칠 때 |
| 🏁    | Windows에서 무언가를 고칠 때 |
| 🔥    | 코드 또는 파일 제거할 때, @CHANGED 주석 태그와 함께 |
| 🚜    | 파일 구조를 변경할 때, 🎨과 함께 사용 |
| 🔨    | 코드를 리팩토링 할 때 |
| ☔️    | 테스트를 추가 할 때 |
| 🔬    | 코드 범위를 추가 할 때 |
| 💚    | CI 빌드를 고칠 때 |
| 🔒    | 보안을 다룰 때 |
| ⬆️    | 종속성을 업그레이드 할 때 |
| ⬇️    | 종속성을 다운그레이드 할 때 |
| ⏩    | 이전 버전 / 지점에서 기능을 전달할 때 |
| ⏪    | 최신 버전 / 지점에서 기능을 백포트 할 때 |
| 👕    | linter / strict / deprecation 경고를 제거 할 때 |
| 💄    | UI / style 개선 시 |
| ♿️    | 접근성을 향상시킬 때 |
| 🚧    | WIP (진행중인 작업)에 커밋, @REVIEW 주석 태그와 함께 사용 |
| 💎    | New Release |
| 🔖    | 버전 태그 |
| 🎉    | Initial Commit |
| 🔈    | 로깅을 추가 할 때 |
| 🔇    | 로깅을 줄일 때 |
| ✨    | 새로운 기능을 소개 할 때 |
| ⚡️    | 도입 할 때 이전 버전과 호환되지 않는 특징, @CHANGED 주석 태그 사용 |
| 💡    | 새로운 아이디어, @IDEA 주석 태그 |
| 🚀    | 배포 / 개발 작업과 관련된 모든 것 |
| 🐘    | PostgreSQL 데이터베이스 별 (마이그레이션, 스크립트, 확장 등) |
| 🐬    | MySQL 데이터베이스 특정 (마이그레이션, 스크립트, 확장 등) |
| 🍃    | MongoDB 데이터베이스 특정 (마이그레이션, 스크립트, 확장 등) |
| 🏦    | 일반 데이터베이스 별 (마이그레이션, 스크립트, 확장명 등) |
| 🐳    | 도커 구성 |
| 🤝    | 파일을 병합 할 때 |

