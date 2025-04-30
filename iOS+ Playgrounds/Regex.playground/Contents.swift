//import UIKit
//
//let txfFileName = "afddk아프카낟nien.box"
//let regex = "^[^<>:;,?\"*|/]+$"
////let regex = "^[\\w,\\s-]+\\.[A-Za-z]{3}$"
////let regex = "[a-zA-Z0-9_ㄱ-힣一-龯ぁ-ゞァ-ヶ\\-.]+"
//
//txfFileName.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil

//import Foundation
//
//let fileName = "fef fef ss"
//var fileNames: [String] = []
//fileNames.append("fef fef ss")
//fileNames.append("fef fef ss copy")
//
//for index in 1...9723 {
//    fileNames.append("fef fef ss copy \(index)")
//}
//
//var result: [String] = []
//if fileNames.contains(fileName) {
//
//    if !fileNames.contains("\(fileName) copy") {
//        print("new Create:", "\(fileName) copy")
//
//    } else {
//        var index = 1
//        while true {
//
//            let targetName = "\(fileName) copy \(index)"
//
//            if fileNames.contains(targetName) {
//                index += 1
//                continue
//            } else {
//                print("new Create:", "\(fileName) copy \(index)")
//                break
//            }
//        }
//    }
//
//
//} else {
//    print("new Create:", fileName)
//}

import Foundation

extension String {
  func removingPtags() -> String {
    var result = self

    // 여는 <p ...> 태그 제거
    let openingPTagPattern = "<p\\b[^>]*>"
    result = result.replacingOccurrences(of: openingPTagPattern,
                                          with: "",
                                          options: .regularExpression)

    // 닫는 </p> 태그 제거
    let closingPTagPattern = "</p>"
    result = result.replacingOccurrences(of: closingPTagPattern,
                                          with: "",
                                          options: .regularExpression)

    return result
  }
}

let string = #"""
<h2><strong>.gitignore 적용 안될때 </strong></h2>
<span class="s1">.gitignore</span>가 제대로 적용되지 않는 경우, 주로 이미 Git에 추적되고 있는 파일이거나 <span class="s1">.gitignore</span> 파일이 잘못 설정된 경우입니다. 이를 해결하기 위한 단계별 점검 및 해결 방법은 아래와 같습니다.
&nbsp;
<h3><b>이미 추적되고 있는 파일인지 확인</b></h3>
<p class="p1"><span class="s1">.gitignore</span>는 Git이 추적하지 않는 파일에만 적용됩니다. 이미 추적 중인 파일은 <span class="s1">.gitignore</span>에 추가해도 무시되지 않습니다.</p>

<h4><b>해결 방법:</b></h4>
<ol start="1">
   <li>
<p class="p1"><b>캐시에서 파일 제거</b></p>
</li>
</ol>
<pre><code>git rm --cached &lt;파일명 또는 디렉터리&gt;</code></pre>
<ol start="1">
   <li>
<p class="p1">예:</p>
</li>
</ol>
<pre><code>git rm --cached -r my_folder/</code></pre>
<ol start="1">
   <li></li>
   <li>
<p class="p1"><b>변경 사항 커밋</b></p>
</li>
</ol>
<pre><code>git commit -m "Remove files from tracking"</code></pre>
<ol start="2">
   <li></li>
   <li>
<p class="p1"><span class="s1">.gitignore</span>에 해당 파일/디렉터리를 추가한 후, 제대로 동작하는지 확인합니다.</p>
</li>
</ol>

<hr />

<h3><b>.gitignore 경로 및 패턴 확인</b></h3>
<p class="p3"><span class="s2">.gitignore</span>의 경로나 작성된 패턴이 정확하지 않을 수 있습니다.</p>

<h4><b>체크 리스트:</b></h4>
<ul>
   <li>
<p class="p1"><b>파일 이름이 정확한지 확인</b><span class="s1">:</span></p>

<ul>
   <li>
<p class="p1"><span class="s1">.gitignore</span>는 파일 이름 앞에 <span class="s1">.</span>이 있어야 하며, 루트 디렉터리에 있어야 합니다.</p>
</li>
</ul>
</li>
   <li>
<p class="p1"><b>패턴 확인</b><span class="s1">:</span></p>

<ul>
   <li>
<p class="p1">특정 디렉터리를 무시하려면 디렉터리 경로 뒤에 <span class="s1">/</span>를 추가해야 합니다.</p>
</li>
</ul>
</li>
</ul>
<pre><code>logs/   # logs 디렉터리 무시
*.log   # 확장자가 .log인 모든 파일 무시</code></pre>
<ul>
   <li>
<ul>
   <li></li>
   <li>
<p class="p1">특정 하위 디렉터리의 파일을 무시하려면 전체 경로를 지정해야 합니다.</p>
</li>
</ul>
</li>
</ul>
<pre><code>/app/cache/   # app 디렉터리 내 cache 디렉터리 무시</code></pre>

<hr />

<h3><b>Git이 .gitignore를 제대로 인식하는지 확인</b></h3>
<p class="p3"><span class="s2">.gitignore</span> 파일 자체가 Git에 의해 무시되고 있을 수 있습니다.</p>

<h4><b>확인 방법:</b></h4>
<pre><code>git check-ignore -v &lt;파일명&gt;</code></pre>
<p class="p1">이 명령어는 특정 파일이 <span class="s1">.gitignore</span>에 의해 무시되는지 확인하고, 관련 규칙을 출력합니다.</p>

<h4><b>해결 방법:</b></h4>
<p class="p1"><span class="s1">.gitignore</span> 파일 자체를 무시하는 항목이 <span class="s1">.git/info/exclude</span>나 상위 <span class="s1">.gitignore</span> 파일에 있는 경우 해당 항목을 제거합니다.</p>


<hr />

<h3><b>.gitignore 강제 재적용</b></h3>
<p class="p1"><span class="s1">.gitignore</span> 수정 후에도 반영되지 않을 경우, 캐시를 완전히 삭제하고 다시 설정해야 합니다.</p>

<h4><b>해결 방법:</b></h4>
<ol start="1">
   <li>
<p class="p1"><b>Git 캐시 초기화</b></p>
</li>
</ol>
<pre><code>git rm -r --cached .</code></pre>
<ol start="1">
   <li></li>
   <li>
<p class="p1"><b>.gitignore 파일이 적용되었는지 확인</b></p>
</li>
</ol>
<pre><code>git status</code></pre>
<ol start="2">
   <li></li>
   <li>
<p class="p1"><b>변경 사항 커밋</b></p>
</li>
</ol>
<pre><code>git add .
git commit -m "Apply updated .gitignore"</code></pre>

<hr />

<h3><b>.gitignore 파일 외부 설정 확인</b></h3>
<ul>
   <li>
<p class="p1">.gitignore<span class="s1"> 외에 </span>.git/info/exclude<span class="s1"> 파일이나 시스템 전체 설정 (</span>~/.config/git/ignore<span class="s1">)에서도 무시 규칙이 적용될 수 있습니다.</span></p>
</li>
</ul>
<h4><b>확인 방법:</b></h4>
<pre><code>cat .git/info/exclude
cat ~/.config/git/ignore</code></pre>

<hr />

&nbsp;

<hr />

&nbsp;
<h2 class="p1"><strong>이미 원격 저장소에 푸시된 커밋을 어멘드(amend)하는 방법</strong></h2>
<p class="p1">이미 GitHub 등 <span class="s1"><b>원격 저장소에 푸시된 커밋을 --amend로 수정하고 다시 푸시하려면</b></span>, **주의사항이 있는 강제 푸시(force push)**를 사용해야 합니다.</p>


<hr />

<h2><b>--amend</b><b>로 마지막 커밋 수정하기</b></h2>
<pre><code>git commit --amend</code></pre>
<p class="p1">이 명령어는 마지막 커밋 메시지를 수정하거나, 파일 추가 등을 수정할 수 있게 해줍니다.</p>
<p class="p1">수정이 끝나면 저장하고 종료하세요.</p>


<hr />

<h2><b>변경된 커밋을 강제로 푸시하기</b></h2>
<pre><code>git push --force</code></pre>
<p class="p1">혹은 리모트 이름이 <span class="s1">origin</span>, 브랜치 이름이 <span class="s1">main</span>이면:</p>

<pre><code>git push origin main --force</code></pre>

<hr />

<h2><b>⚠️ 주의: </b><b>--force</b><b>는 신중하게!</b></h2>
<ul>
   <li>
<p class="p1"><span class="s1">--amend</span><span class="s2">는 </span><b>커밋 해시를 변경</b><span class="s2">합니다.</span></p>
</li>
   <li>
<p class="p1"><span class="s1">이미 푸시된 커밋을 바꾸면, </span><b>공동 작업자가 있을 경우 그들의 히스토리를 깨뜨릴 수 있습니다.</b><b></b></p>
</li>
   <li>
<p class="p1"><span class="s1">따라서 </span><b>혼자 작업하거나, 팀원과 협의 후에만 사용</b><span class="s1">하세요.</span></p>
</li>
</ul>
<blockquote>🔐 안전하게 강제 푸시하려면 <span class="s2">--force-with-lease</span> 사용도 고려:</blockquote>
<pre><code>git push --force-with-lease</code></pre>
<p class="p1">이 명령은 “내 로컬이 최신 상태가 맞다면 강제 푸시”를 허용합니다.</p>


<hr />

<h2><b>✅ 요약</b></h2>
<table>
<thead>
<tr>
<th>
<p class="p1"><b>작업</b></p>
</th>
<th>
<p class="p1"><b>명령어</b></p>
</th>
</tr>
</thead>
<tbody>
<tr>
<td>
<p class="p1">마지막 커밋 수정</p>
</td>
<td>
<p class="p1">git commit --amend</p>
</td>
</tr>
<tr>
<td>
<p class="p1">수정된 커밋 푸시</p>
</td>
<td>
<p class="p1">git push --force</p>
</td>
</tr>
<tr>
<td>
<p class="p1">안전한 강제 푸시</p>
</td>
<td>
<p class="p1">git push --force-with-lease</p>
</td>
</tr>
</tbody>
</table>

<hr />

<h2><strong>깃허브 오픈소스 라이브러리에 풀 리퀘스트 (Pull Request) 하는 방법</strong></h2>

<hr />

<h3><b>1. 프로젝트 포크(Fork)</b></h3>
<p class="p1">PR을 보내려면 먼저 해당 오픈소스 프로젝트를 <span class="s2"><b>Fork</b></span>해야 합니다.</p>

<ol start="1">
   <li>
<p class="p1">GitHub에서 기여하려는 리포지토리로 이동합니다.</p>
</li>
   <li>
<p class="p1">우측 상단에 있는 <span class="s1"><b>“Fork”</b></span> 버튼을 클릭합니다.</p>
</li>
   <li>
<p class="p1">내 GitHub 계정으로 포크된 리포지토리가 생성됩니다.</p>
</li>
</ol>

<hr />

<h3><b>2. 로컬에 클론(Clone)</b></h3>
<p class="p1">포크한 리포지토리를 로컬 환경으로 가져옵니다.</p>

<pre><code>git clone https://github.com/내-깃허브-이름/프로젝트이름.git
cd 프로젝트이름</code></pre>
<p class="p1">원본(upstream) 저장소를 추가하여 최신 코드와 동기화할 수 있도록 설정합니다.</p>

<pre><code>git remote add upstream https://github.com/원본-저장소-이름/프로젝트이름.git
git fetch upstream</code></pre>

<hr />

<h3><b>3. 새 브랜치 생성</b></h3>
<p class="p3">기여할 기능이나 버그 수정을 위해 새로운 브랜치를 생성합니다.</p>

<pre><code>git checkout -b fix/issue-123</code></pre>
<p class="p1">브랜치 이름은 보통 <span class="s1">fix/버그번호</span> 또는 <span class="s1">feature/기능이름</span> 형식으로 정합니다.</p>


<hr />

<h3><b>4. 코드 수정 및 커밋</b></h3>
<p class="p1">이제 코드를 수정한 후 변경 사항을 커밋합니다.</p>

<pre><code>git add .
git commit -m "fix: 버그 수정 내용 또는 기능 추가 내용"</code></pre>
<p class="p1">커밋 메시지는 일반적으로 다음과 같은 형식을 따르는 것이 좋습니다.</p>

<ul>
   <li>
<p class="p1"><span class="s1">fix: ~</span> (버그 수정)</p>
</li>
   <li>
<p class="p1"><span class="s1">feat: ~</span> (새로운 기능 추가)</p>
</li>
   <li>
<p class="p1"><span class="s1">docs: ~</span> (문서 수정)</p>
</li>
   <li>
<p class="p1">refactor: ~<span class="s1"> (코드 리팩토링)</span></p>
</li>
</ul>

<hr />

<h3><b>5. 포크된 리포지토리에 푸시(Push)</b></h3>
<p class="p1">포크한 내 저장소에 변경 사항을 올립니다.</p>

<pre><code>git push origin fix/issue-123</code></pre>

<hr />

<h3><b>6. Pull Request(PR) 생성</b></h3>
<ol start="1">
   <li>
<p class="p1">GitHub에서 내 포크된 리포지토리로 이동합니다.</p>
</li>
   <li>
<p class="p1">“Compare &amp; pull request” 버튼을 클릭합니다.</p>
</li>
   <li>
<p class="p1">PR 제목과 설명을 작성합니다.</p>

<ul>
   <li>
<p class="p1">변경 사항을 간략하게 설명하고, 왜 필요한지 추가합니다.</p>
</li>
   <li>
<p class="p1">관련 이슈가 있다면 <span class="s1">Closes #123</span> 형식으로 연결합니다.</p>
</li>
</ul>
</li>
   <li>
<p class="p1">“Create Pull Request” 버튼을 클릭합니다.</p>
</li>
</ol>

<hr />

<h3><b>7. 코드 리뷰 및 피드백 반영</b></h3>
<ul>
   <li>
<p class="p1">프로젝트 관리자가 리뷰를 남길 수 있습니다.</p>
</li>
   <li>
<p class="p1">수정이 필요하면 다시 코드를 변경한 후 푸시하면 PR에 자동 반영됩니다.</p>
</li>
</ul>
<pre><code>git add .
git commit --amend -m "수정된 내용 추가"
git push origin fix/issue-123 --force</code></pre>

<hr />

<h3><b>8. PR 머지 및 정리</b></h3>
<p class="p3">PR이 승인되면 프로젝트 관리자가 PR을 머지합니다.</p>
<p class="p3">머지된 후, 로컬과 포크된 저장소를 정리합니다.</p>

<pre><code>git checkout main
git pull upstream main
git push origin main
git branch -d fix/issue-123</code></pre>
<p class="p1">이제 PR이 성공적으로 반영되었습니다!</p>
&nbsp;

[rcblock id="6686"] 
"""#

print(string.removingPtags())
