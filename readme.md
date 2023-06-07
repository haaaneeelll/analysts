
CLI에서 자주 쓰는 코드들
- ls : list
- touch : 빈파일
- rm  : remove
- makdir : make directory
- cd   : change directory
- cd.. : 상위폴더
- pwd print working directory: 현재 디렉토리


### git이란?
분산 버전 관리 시스템
버전: 소프트웨어 트정 상태. 즉 소스코드의 상태
컴퓨터 파일의 변경사항 추적

작업을 하고/ 변경된 파일을 모아/ 버전으로 남긴다(add)

![](https://velog.velcdn.com/images/jhaneul/post/45b9ff8d-6fd4-4aca-89d5-153fbe2a5e4d/image.png)
왜 깃을 모았다가(add) 커밋하는 것일까?
개발자들은 프로젝트를 진행하면서 파일들을 수정하고 변경 사항을 반영한다. git은 모든 수정된 파일을 자동을 추적하지 않는다.
add으로 스테이징 된 파일들만 추적 대상으로 여겨 커밋한다.

### Scope
기존에 깃허브를 개인프로젝트 관리용으로 사용했습니다. 
프로젝트와 알고리즘 공부할 때 vs code를 적극 사용하고 있어 작성한 코드를 TIL로 남겨보가자 git 연동방법을 찾아보게되었습니다.
첨언을 더 하자면 
개발자가 된다 다짐하고 이제 한달이 되어 이것도 익숙치 않지만...
vscode로 커밋을 하는 과정에서 어려움을 겪었습니다. 
저처럼 잘 안되시는 분을 위하여 써봅니다.
## 준비물
**1. git 설치** : 당연히 본인 컴퓨터에 git이 필수적으로 설치되어 있어야 합니다. (설치법은 간단하기 때문에 알아서 구글링으로 설치)

**2. IDE **: 옵션 사항입니다. 터미널창도 충분합니다. 저는 vscode가 직관적이라 좋습니다.

**3. git 관리 프로그램** : 이 또한 옵션 사항입니다. CLI가 익숙하지 않은 사람은 IDE 또한 익숙하지 않을 수 있습니다.(VSCode라면 더더욱). Source Tree, GitKraken, GitHub Desktop 등, git 인터페이스를 GUI로 만들어 준 응용 프로그램들이 많습니다.

저는 그냥 VSCode의 터미널 창을 활용해서 사용합니다.
# 기본 setup
먼저 git으로 관리할 폴더를 열어주고
[Ctrl] + [Shift] + [`] 단축키를 입력하여 터미널 창을 열어줍니다.
위와 같이 쉘이 열리고 현재 작업중인 폴더에 자동으로 이동한 것을 볼 수 있습니다.
이게 매우 편하기 때문에 OS의 기본 터미널이 아닌 VSCode로 작업하는 것이 더 편합니다..
![](https://velog.velcdn.com/images/jhaneul/post/4e06c3a4-6a3b-4b35-b603-dee56488f8fb/image.png)

## git init
좌측의 tree 창에서 볼 수 있듯이 내가 관리하고자 하는 폴더에는 .vscode 폴더가 하나가 존재합니다.
이 폴더는 파이썬 기반의 테스트코드가 담긴 폴더입니다.
마찬가지로 해당 폴더를 git으로 관리하려면 .git 폴더가 필요합니다.
아래와 같이 입력하여 git을 시작합니다.
```
git init
```
이렇게 git init을 하면 달라진 것이 있습니다.
![](https://velog.velcdn.com/images/jhaneul/post/99d61ed0-0cc3-4286-b02f-c9535d3e5266/image.png)

**1. vscode 좌측 상단에 master가 생겼습니다.**
새롭게 git을 시작했으므로 master 브랜치가 생긴 것입니다.


**2. 좌측 tree의 모든 폴더와 파일이 초록색으로 변했습니다.**
그리고 추가로 U 라는 글씨가 생긴것을 볼 수 있습니다.
이 U는 VSCode에서 git을 사용할 때 지원해주는 기능인데, Untracked라는 뜻이다.
이 untracked는 밑에서 다시 살펴볼 수 있다.
정리하자면, 이제 git은 이 폴더 내에서 존재하는 모든 변화하는 모든 사항들을 기록할 것이다.

**3. VSCode의 제일 좌측 Activity Bar에 Source Control 패널에 1라는 숫자가 생겨났습니다.**
이 또한 VSCode가 지원하는 기능 중 하나라로, 이제 해당 폴더를 git이 지켜보고 있으니 지원하기 시작했다고 생각하면 된다.
정리하자면 "이제 해당 폴더는 git께서 굽어다보고 계신다"라고 생각하면 된다.
폴더내의 모든 폴더, 파일, 내용까지의 변화를 감시한다.

## 
git config
아래 명령어를 입력해서 본인이 사용하고자 하는 GitHub의 username과 email을 입력합니다.
```
    git config --global user.name "본인계정이름"
    git config --global user.email "본인이메일주소"
```
나는 이미 해당 맥북에 입력한 상태여서 생략하겠습니다.

## 1-1.git status
```
git status
```
위 명령어를 입력해봅니다.
![](https://velog.velcdn.com/images/jhaneul/post/4885f94c-bd74-49ef-9e47-601e388f0ebc/image.png)

현재 브랜치 master : 지금 내가 master 브랜치를 보고 있다는 상태를 보여줍니다.
아직 커밋이 없습니다 : 아직 내가 커밋한 적이 없다는 것을 알려줍니다.
추적하지 않는 파일 : 아래 것들이 내가 커밋할 녀석들입니다.

터미널에서 영어로 나오는 부분들인데...한국어로 나오니 감사합니다.
**정리하자면, git이 폴더를 감시하는것은 맞지만, 어떤 것을 감시할 것인지 우리가 추가해줘야 하는 것입니다.
**
따라서 위에 터미널에서 빨간 색으로 표시된 .vscode/와 v0/ 폴더를 추가하라는 뜻입니다.

대충
**git : "내가 이 폴더를 감시중인데, 아래의 파일들이 새로 만들어진 듯 하니, 내 감시 목록에 올려라"라는 뜻으로 이 감시 목록에 올리는 행위를 'add'이라고 합니다.**
## 1-2.git add
```
git add -A
```
![](https://velog.velcdn.com/images/jhaneul/post/378db5fb-f82e-4bde-bf82-2a175a39b228/image.png)
**1. master 브랜치 옆에 +가 생겼습니다.**
말 그대로 untracked 되던 파일들을 add(+) 했으니 사용자에게 add한 사항이 있다는 걸 알려주기 위한 것입니다.
정확히는 "add된 항목들이 있으니 commit해라"라는 뜻입니다.

**2. 좌측 tree에 U(untracked)가 A(added)로 바뀌었습니다.**
다시 git status를 입력해보면 상태가 바뀐 것을 알 수 있습니다.

## 1-3.git commit
> 위에서 add한 파일들이 있는 공간을 **스테이지(stage)**라고 부릅니다.
선수들이 경기장 위에 입장은 했는데, 아직 경기가 시작되지 않은 것입니다.
이제 git을 저장하기 위해 작업을 할겁니다. 경기가 시작됩니다.

```
git commit -m "적으시고 싶은 comment를 작성하시면 됩니다!"
```
-m 옵션 뒤에 메모하고 싶은 말을 적습니다.
![](https://velog.velcdn.com/images/jhaneul/post/c703c428-deaa-432e-82ad-ac3abe3733b1/image.png)

**1. master 브랜치 옆의 + 표시가 사라지고 색이 초록색으로 바뀌었습니다.
2. 좌측 tree와 Source Control 패널이 깔끔해졌습니다.**
왜 깔끔해졌는지는 git status를 입력해보면 알 수 있습니다.
![](https://velog.velcdn.com/images/jhaneul/post/b7d3aff8-7060-40fb-8e6c-8cd7d87c1801/image.png)
# 2.깃허브
여기까지의 진행 사항들을 그대로 GitHub에 public으로 올릴 것입니다.
## 2-1.깃허브 저장소 만들기
![](https://velog.velcdn.com/images/jhaneul/post/cda21aba-04ef-45de-84a2-7f56da9fb4a8/image.png)
깃허브에 로그인해서 저장소를 만들어줍니다. 레포지토리가 저장소입니다.
관련해서 공식문서를 첨부합니다.
[링크텍스트](https://docs.github.com/ko/get-started/quickstart/create-a-repo)
## 2-2. GitHub 원격 저장소에 로컬 저장소를 push 하기
> 짚고 넘어갈 용어들이 있습니다.
내 컴퓨터 상에 존재하는 저장소를 로컬 저장소(local repository)라 하고, GitHub와 같은 인터넷상에서 존재하는 저장소를 원격 저장소(remote repository)라고 합니다.
원격 저장소를 활용하는 이유는 당연히 여러 기기에서(여러명이) 하나의 프로젝트를 관리할 수 있기 때문입니다.
이렇게 원격 저장소에 로컬 저장소를 올리는 행위를 푸쉬(push)라고 합니다.
당연히 반대의 행위는 풀(pull)이라고 하고 편하게 땡겨옵니다.

![](https://velog.velcdn.com/images/jhaneul/post/d046cd23-e2ce-4337-8445-374636a9a233/image.png)

![](https://velog.velcdn.com/images/jhaneul/post/e837a8ac-c753-473a-a8f0-de94b1bf896c/image.png)
Create repository 버튼을 누르면 위와 같은 화면을 볼 수 있습니다.
맨 위에는 내 원격 저장소의 링크가 생겨난 것을 볼 수 있고, 아래 3가지 옵션이 나와있습니다.
이 옵션들은 곧 만들어질 원격 저장소에 연결할 다른 저장소(나는 로컬 저장소에 해당된다)를 어떻게 업로드(push)하는지 알려주고 있습니다.
저는 이미 존재하는 로컬 저장소를 푸쉬할 것이므로 두 번째 명령어를 사용할 것입니다.
```
git remote add origin url
git branch -M main
git push -u origin main
```
위의 세줄을 순서대로 터미널 창에 입력해줍니다. 헷갈리니 하나씩 써주세요.
![](https://velog.velcdn.com/images/jhaneul/post/f117898c-0b96-4797-be61-32fb904f4916/image.png)
처음 하는 경우 사용자의 로그인 정보를 물어볼텐데 이는 알아서 잘 입력하시면 됩니다.
잘 push 되었는지 확인하려면 열어놓았던 GitHub 페이지를 새로고침 해 봅니다.
![](https://velog.velcdn.com/images/jhaneul/post/9e250267-d29c-4586-8334-486ab6dd4dc0/image.png)
축하드립니다. vs code를 통해 
첫 커밋이 완성되었습니다.











