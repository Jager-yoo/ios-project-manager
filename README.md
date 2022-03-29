# 📱 <프로젝트 관리 앱> 시연 영상

> 할 일을 3개의 단계(Todo, Doing, Done)로 구분하여 관리할 수 있는 아이패드 전용 앱

https://user-images.githubusercontent.com/71127966/160186136-98a09970-bc8e-4d9b-94c7-fdfd16baf7ac.mov

<br>

# 🧰 적용 기술 선정

|UI|비동기 이벤트 처리|Local DB|Remote DB|의존성 관리 도구|
|:-:|:-:|:-:|:-:|:-:|
|[SwiftUI](https://developer.apple.com/kr/xcode/swiftui/)|[Combine](https://developer.apple.com/documentation/combine)|[Realm](https://github.com/realm/realm-swift)(미구현)|[Firebase](https://github.com/firebase/firebase-ios-sdk)(미구현)|[Swift Package Manager](https://www.swift.org/package-manager/)|

<br>

# ⚙️ [STEP 2-2] 기본 UI 및 Cell 간의 이동, 삭제, 수정 등의 비즈니스 로직 구현

<details>
<summary><h3>1️⃣ MVVM 패턴 적용</h3></summary>

- 뼈대가 되는 View 구조체들이 프로퍼티로 `@EnvironmentObject`, `@StateObject` 만 갖고, 그 외의 비즈니스 로직이나 상수는 전부 `뷰모델` 내로 이동시켰습니다! 👍🏻

- Paul Hudson 의 영상인 [Introducing MVVM into your SwiftUI project](https://youtu.be/kfsA87qRC3Y?t=133)를 참고했는데요, Paul 은 뷰모델을 구현할 때, View 구조체의 `extension`을 만들고 `nested 뷰모델 클래스`를 구현하는 방식을 관찰했습니다.
이런 방식으로 하면, View 구조체들이 자신의 뷰모델만 접근할 수 있고 다른 뷰모델은 알지 못하기 때문에, `인터페이스 분리 원칙`을 더 잘 지킬 수 있습니다.

- 저는 View 구조체와 뷰모델의 파일이 별도로 분리되는 것도 복잡성을 늘린다고 판단하여, View 구조체가 구현된 파일에 `private extension`으로 뷰모델을 구현하여 뷰와 뷰모델의 관계를 좀 더 직관적으로 파악할 수 있도록 했습니다.

```swift
struct TaskListView: View {

    @EnvironmentObject var taskManager: TaskManager
    @StateObject private var taskListViewModel: TaskListViewModel
    // 나머지 코드...
}

private extension TaskListView {
    
    final class TaskListViewModel: ObservableObject {
    
        // 뷰모델의 프로퍼티, 이니셜라이저, 메서드 ...
    }
}
```
</details>

<details>
<summary><h3>2️⃣ DatePicker 지역화 구현</h3></summary>

- SwiftUI 의 [DatePicker](https://developer.apple.com/documentation/swiftui/datepicker)는 디폴트로 `영어 인터페이스`를 보여줍니다.

- `지역화`를 위한 좋은 대상이라고 생각하여, 실행 기기의 선호 언어 배열인 `Locale.preferredLanguages`에 접근하여, 가장 우선순위가 높은 언어(first)를 꺼내 locale 을 설정해줬습니다.
  - 이때, 옵셔널이 나온다면 디폴트인 영어를 보여줄 수 있도록 했습니다.
  - 아래는 한국어, 일본어, 우크라이나어가 적용된 예시 이미지입니다.

|🇰🇷 설정|🇯🇵 설정|🇺🇦 설정|
|:-:|:-:|:-:|
|<p align="left"><img src="https://user-images.githubusercontent.com/71127966/160180371-f06786cc-a365-4a50-a4c1-a01cbe445b4b.png" width="100%"></p>|<p align="left"><img src="https://user-images.githubusercontent.com/71127966/160180382-7248adfb-acb6-4b5f-86da-8fc492579621.png" width="100%"></p>|<p align="left"><img src="https://user-images.githubusercontent.com/71127966/160180391-82173e4b-4130-4b7e-827d-baacd0a0d8f3.png" width="100%"></p> |

```swift
struct CustomDatePicker: View {
    
    @Binding var taskDueDate: Date
    private let defaultDatePickerLanguage: String = "en"
    
    var body: some View {
        DatePicker("", selection: $taskDueDate, displayedComponents: .date)
            .labelsHidden()
            .datePickerStyle(.wheel)
            .scaleEffect(1.2)
            .padding(.vertical, 20)
            .environment(\.locale, Locale(identifier: Locale.preferredLanguages.first ?? defaultDatePickerLanguage))
    }
}
```
</details>

<details>
<summary><h3>3️⃣ NavigationBar 커스터마이징을 위한 ViewModifier 구현</h3></summary>

- SwiftUI 에서는 `NavigationBar` 위에 올라가는 Text 의 font, foregroundColor, tintColor, shadowColor 등을 커스터마이징할 수 없습니다.

<img width="660" alt="navigationTitle 에는 unstyled text 만 들어갈 수 있다 - SwiftUI" src="https://user-images.githubusercontent.com/71127966/160174892-8eb35625-e019-4cc9-b45e-80f8ef1733ec.png">

- [Navigation Bar Styling in SwiftUI](https://youtu.be/kCJyhG8zjvY) 영상을 참고하여, `ViewModifier 프로토콜`을 준수하는 구조체를 구현했습니다.

- View 타입의 extension 으로 메서드(modifier) 구현하여, 가장 상위의 NavigationView 에 적용했습니다.

- NavigationBar 에 올라가는 Title 의 font, foregroundColor, 버튼의 색상인 tintColor, Bar 의 경계선을 감출 것인지 여부를 선택할 수 있게 만들었습니다.

```swift
struct NavigationBarAppearanceModifier: ViewModifier {
    
    init(font: UIFont.TextStyle, foregroundColor: UIColor, tintColor: UIColor?, hideSeparator: Bool) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.titleTextAttributes = [
            .font: UIFont.preferredFont(forTextStyle: font),
            .foregroundColor: foregroundColor
        ]
        if hideSeparator {
            navigationBarAppearance.shadowColor = .clear
        }
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        if let tintColor = tintColor {
            UINavigationBar.appearance().tintColor = tintColor
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    
    /// NavigationBar 의 font, foregroundColor, tintColor 를 변경합니다. hideSeparator 를 true 로 바꾸면 Bar 의 경계선을 비활성화할 수 있습니다.
    func navigationBarAppearance(font: UIFont.TextStyle, foregroundColor: UIColor, tintColor: UIColor? = nil, hideSeparator: Bool = false) -> some View {
        self.modifier(NavigationBarAppearanceModifier(font: font, foregroundColor: foregroundColor, tintColor: tintColor, hideSeparator: hideSeparator))
    }
}
```
</details>

<details>
<summary><h3>4️⃣ TextEditor 위에 커스텀 Placeholder 기능 추가</h3></summary>

- SwiftUI 에서 제공하는 [TextEditor](https://developer.apple.com/documentation/swiftui/texteditor)에는 `Placeholder` 기능이 없습니다.

- 다행히, 이전 프로젝트인 `<오픈마켓>` 당시에도, 비슷한 문제 해결 경험이 있습니다.
UIKit 에서 제공하는 [UITextView](https://developer.apple.com/documentation/uikit/uitextview)에도 똑같이 Placeholder 기능이 없어서, 별도의 View 를 `Z축으로` UITextView 위에 올리고, 내용이 채워지면 `isHidden` 처리를 해주는 식으로 문제를 해결했었습니다.

- SwiftUI 에서도 비슷한 방식으로 만들어보려 했는데, `ZStack` 이라는 아주 편리한 기능이 있는 반면에, `isHidden` 프로퍼티는 존재하지 않았습니다. 🤷‍♂️
구글링을 해보니 `isHidden`을 대체하기 위한 다양한 접근 방법이 있더라구요. [Dynamically hiding view in SwiftUI](https://stackoverflow.com/questions/56490250/dynamically-hiding-view-in-swiftui)

- 저는 View 의 `투명도`를 조절하는 `opacity` modifier 를 사용했습니다!
해당 리팩토링을 진행하며, `TextEditor`와 Placeholder 를 묶어서 -> 별도의 구조체인 `TextEditorWithPlaceholder` 로 파일 분리했습니다.

https://user-images.githubusercontent.com/71127966/158437488-aa3eb851-3d60-4e33-ada8-888a9b7eba5d.mov

</details>

<details>
<summary><h3>5️⃣ 에러 발생 시, Alert 를 통해 안내</h3></summary>

- 에러 발생 시, `Alert` 를 띄워서, 사용자에게 앱 종료 후 문의를 안내하도록 했습니다. 😄

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/159407922-8a96bc6d-506b-45a2-a80d-2cd496ec49d0.png" width="30%"></p> 

```swift
// 별도의 파일에 열거형과 static let 으로 Alert 구조체를 미리 만들어뒀습니다. for 재사용
enum AlertManager {
    
    static let errorAlert = Alert(
        title: Text("에러가 발생했어요 🥺"),
        message: Text("앱 종료 후, 개발자에게 문의해주세요"),
        dismissButton: .default(Text("알겠어요"))
    )
}

// 사용하는 부분 예시
.alert(isPresented: $taskListRowViewModel.isErrorOccurred) {
    AlertManager.errorAlert
}
```
</details>

<details>
<summary><h3>6️⃣ 현재 날짜와 하루 차이가 나는 걸 판단하는 로직</h3></summary>

- 요구사항을 보면, `기한`이 지난 날짜는 빨간색으로 글자 색을 변경해줘야 합니다.

- 저는 할일(Task) Entity 에서 날짜는 `Date` 타입으로 선언했습니다.
이를 활용하기 위해, Date 타입의 `extension`을 아래와 같이 구현했습니다.

- [DateFormatter 인스턴스 생성 비용](https://sarunw.com/posts/how-expensive-is-dateformatter/)을 줄이기 위해, private static let 으로 만들고 `locale, timeZone, dateStyle` 을 설정해줬습니다.
Date 인스턴스를 포맷팅된 String 타입으로 만들어주는 연산 프로퍼티인 `dateString`을 구현했습니다.

- `isOverdue` 연산 프로퍼티가, `Date 인스턴스의 기한이 하루 이상 지났는지 판단`해주는 기능을 합니다.
dateString 으로, 포맷팅된 String 으로 바꾼 걸 다시 Date 타입으로 변환해서 `'시간' 데이터 없이 '날짜' 데이터만 남긴 상태로 크기 비교`를 합니다.
이때, 옵셔널에 `nil`이 잡히더라도, 비교는 가능하도록 닐병합연산자 넣어줬습니다.

```swift
extension Date {
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    var dateString: String {
        return Self.dateFormatter.string(from: self)
    }
    
    var isOverdue: Bool {
        let targetDate = Self.dateFormatter.date(from: self.dateString) ?? Date(timeIntervalSince1970: self.timeIntervalSince1970)
        let currentDate = Self.dateFormatter.date(from: Date().dateString) ?? Date()
        return targetDate < currentDate
    }
}
```
</details>

<br>

# ⚙️ [STEP 2-1] 모델 타입 구현

<details>
<summary><h3>1️⃣ '할일'을 표현하기 위한 Task, TaskStatus 타입 구현</h3></summary>

- 이번 프로젝트에서 다뤄야 하는 주요 `Entity`는 `할일(Task)`입니다.
- Entity 객체 간의 Identity 를 구별하기 위해 `id` 값을 let 프로퍼티로 선언했습니다.
- 그 외의 title, body, dueDate, status 는 변경될 수 있는 값이므로, var 프로퍼티로 선언했습니다.
- id 는 불변이지만, 그 외의 프로퍼티는 자주 수정될 수 있습니다.
값타입인 `구조체`에서 `mutating` 키워드를 붙이기 보다는, `클래스` 타입으로 모델을 구현했습니다.
  - ⚠️ [모델을 클래스로 구현한 경우의 단점](https://github.com/yagom-academy/ios-project-manager/pull/81#discussion_r820076932)
- Task 인스턴스가 생성될 때, id 는 String 타입으로 자동 생성되도록 `이니셜라이저`를 만들었습니다.
- 기한(dueDate)은 모델에서 `Date` 타입으로 관리합니다.
그러면 `Firebase`에 업로드할 땐 `Timestamp` 타입이 되고, 다운로드 할 때는 [dateValue()](https://firebase.google.com/docs/reference/swift/firebasefirestore/api/reference/Classes/Timestamp#datevalue) 메서드를 사용하여 다시 Date 타입으로 변환할 수 있습니다.
- Task 가 생성될 때는 기본적으로 `TODO` status 로 설정됩니다.
- Task 인스턴스 간의 `동일성(id 매칭)`을 확인할 때 `==` 연산자를 사용할 수 있도록 `Equatable` 프로토콜을 채택했습니다.

```swift
final class Task: ObservableObject, Identifiable, Equatable {
    
    let id: String
    @Published var title: String
    @Published var body: String
    @Published var dueDate: Date
    @Published var status: TaskStatus
    
    init(title: String, body: String, dueDate: Date) {
        self.id = UUID().uuidString
        self.title = title
        self.body = body
        self.dueDate = dueDate
        self.status = .todo
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
    }
}

enum TaskStatus: CaseIterable {
    
    case todo
    case doing
    case done
    
    var headerTitle: String {
        switch self {
        case .todo:
            return "TODO"
        case .doing:
            return "DOING"
        case .done:
            return "DONE"
        }
    }
}
```
</details>

<details>
<summary><h3>2️⃣ 데이터 관리를 담당하는 TaskManager 타입과 추상화 프로토콜 구현</h3></summary>

- TaskManager 클래스는 할일(Task)들을 `배열` 형태로 가지고 있습니다.
- 추후 3개의 `UITableView(List)`를 구현할 때 `DataSource`로서 데이터를 전달해야 하므로, Status 별로 배열을 필터링해서 리턴해주는 메서드를 구현했습니다.
  - 할일(Task)을 보여줄 때, dueDate 가 `오래된 순서대로 정렬`될 수 있도록, filter 후에 sorted 처리해서 리턴합니다.
- TaskManager `기능의 추상화`를 위해 TaskManageable 프로토콜 구현했습니다.
- Task 수정 메서드는 파라미터로 `옵셔널 Task?`를 받고, 내부에서 `옵셔널 바인딩`을 하고 에러를 던질 수 있습니다.

```swift
final class TaskManager: ObservableObject, TaskManageable {
    
    @Published private var tasks = [Task]()
    
    func fetchTasks(in status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }.sorted { $0.dueDate < $1.dueDate }
    }
    
    func validateTask(title: String, body: String) -> Bool {
        return title.isEmpty == false && body.count <= 1000
    }
    
    func createTask(title: String, body: String, dueDate: Date) {
        let newTask = Task(title: title, body: body, dueDate: dueDate)
        tasks.append(newTask)
    }
    
    func editTask(target: Task?, title: String, body: String, dueDate: Date) throws {
        guard let target = target else {
            throw TaskManagerError.taskIsNil
        }
        
        target.title = title
        target.body = body
        target.dueDate = dueDate
    }
    
    func changeTaskStatus(target: Task?, to status: TaskStatus) throws {
        guard let target = target else {
            throw TaskManagerError.taskIsNil
        }
        
        target.status = status
    }
    
    func deleteTask(indexSet: IndexSet, in status: TaskStatus) throws {
        guard let convertedIndex = indexSet.first else {
            throw TaskManagerError.taskIsNil
        }
        
        let target = fetchTasks(in: status)[convertedIndex]
        
        guard let targetIndex = tasks.firstIndex(of: target) else {
            throw TaskManagerError.taskIsNil
        }
        
        tasks.remove(at: targetIndex)
    }
}
```
</details>

<details>
<summary><h3>3️⃣ TaskManager 기능에 대한 Unit Test 코드 작성</h3></summary>

- `setUpWithError`, `tearDownWithError` 메서드를 이용해서 각 케이스 메서드가 모두 동일한 조건에서 실행될 수 있도록 했습니다.
- 테스트 메서드는 7개 작성했으며, 앞으로 추가될 수 있습니다. 😄
  - Task 인스턴스 생성 검증
  - TaskStatus 변경 검증
  - Task 수정 검증
  - Task 수정 실패(에러) 검증
  - TaskStatus 변경 후 삭제 검증
  - TaskStatus 변경 실패(에러) 검증
  - Task 생성 후 dueDate 오래된 순서로 정렬 검증

</details>

<br>

# ⚙️ [STEP 1] 라이브러리 의존성 추가 및 환경 설정

<details>
<summary><h3>1️⃣ SwiftUI -> UIKit Intergration</h3></summary>

- UIKit 으로 만들어진 기존 프로젝트에 `SwiftUI` 프레임워크를 적용했습니다.
- 스토리보드와 ViewController.swift 파일을 삭제하고 `ContentView.swift` 파일을 만들어서 SwiftUI 스타일로 구성했습니다.
- [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller)를 이용하여 rootVC 를 `SwiftUI view`로 wrapping 했습니다.
  - 📄 참고 문서 -> [SwiftUI Views Displayed by Other UI Frameworks](https://developer.apple.com/documentation/swiftui/swiftui-views-displayed-by-other-ui-frameworks)

```swift
// SceneDelegate.swift

func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let hostingVC = UIHostingController(rootView: ContentView())
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = hostingVC
    window?.makeKeyAndVisible()
}
```
</details>

<details>
<summary><h3>2️⃣ Firebase, Realm 라이브러리 추가</h3></summary>

- 데이터 저장을 위해 사용할 Firebase, Realm 라이브러리를 `Swift Package Manager`를 통해 의존성 추가했습니다.

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156405675-cccd5127-2ca4-4b02-bcee-9c66b0e8bef0.png" width="40%"></p>

</details>

<details>
<summary><h3>3️⃣ Firebase Realtime DB 연동 체크</h3></summary>

- Firebase 의 `Realtime Database` 기능을 사용하기 위해 [해당 블로그](https://ios-development.tistory.com/231?category=899471) 참고하여 테스트를 진행했습니다.
- SwiftUI 프레임워크에서는 viewDidLoad() 메서드를 사용할 수 없어서, [onAppear(perform:)](https://developer.apple.com/documentation/swiftui/view/onappear(perform:)) 메서드를 사용했습니다.

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156117315-5ea9a249-6310-4c35-bbfe-f84b0c3b4406.png" width="100%"></p>

</details>

<details>
<summary><h3>4️⃣ Firebase Cloud Firestore 전환 및 연동 체크</h3></summary>

- 기존에 Firebase `Realtime DB`를 사용하기로 했는데요, `Firestore`가 상대적으로 [더 업그레이드된 최신의 DB](https://firebase.google.com/docs/firestore/rtdb-vs-firestore?hl=ko)이고, 현업에서도 Realtime -> Firestore 로 전환하는 추세라는 조언을 들었습니다.
- Realtime, Firestore 간의 가장 큰 차이는 [과금 모델](https://firebase.google.com/pricing?hl=ko)이라고 생각했습니다.
  - `Free tier`에서는 둘 다 약 1GB 정도의 데이터만 저장할 수 있습니다.
  - Firestore 는 `하루 CRUD 횟수`에 제한이 있고 Realtime 은 저장된 데이터 크기, 다운로드 크기에 제한이 있습니다.
  - 즉, 큰 단위의 데이터 요청이 자주 발생한다면 Firestore 가 유리하고, 가벼운 데이터이지만 CRUD 요청이 많이 발생한다면 Realtime 이 유리합니다.
  - 이번 프로젝트에서 다루는 `데이터는 text 뿐`이고 이미지 조차 없기 때문에, 데이터 크기는 작지만, CRUD 요청이 많이 발생할 것입니다.
  - 만약 `과금 모델`만을 고려하면 Realtime 을 사용하는 게 유리한 선택이지만, 그럼에도 저는 Firebase 의 최신 DB인 `Firestore`를 선택해 경험해보고자 합니다.
- Firebase SDK 중에서 `FirebaseFirestore`를 추가하고 `FirebaseDatabase`는 제거했습니다.
- 간단한 연동 테스트를 진행했습니다.

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156418104-ca47c24a-0123-479f-815e-535b02ea3bfc.png" width="70%"></p>

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156413686-30419ca2-e4db-4fb4-9e58-d0f39dbb4899.png" width="70%"></p>

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156414374-77a0022b-0387-4259-9785-19e009c2166b.png" width="100%"></p>

</details>

<details>
<summary><h3>5️⃣ Homebrew 이용한 SwiftLint 추가</h3></summary>

- `SwiftLint(린트)`는 SPM 을 지원하지 않습니다.
- 린트를 세팅하기 위해 `CocoaPods`를 추가하기엔 의존성 도구가 2개로 나뉘어져 관리의 불편함이 생길 거라 생각했습니다.
- [린트 공식 리드미](https://github.com/realm/SwiftLint#using-homebrew)를 참고하여, `Homebrew`를 이용해 린트 설치를 쉽게 완료했습니다.
- 세팅 순서
  - 터미널에서 `brew install swiftlint` 명령어를 입력합니다.
  - Xcode 의 `Build Phases`에서 `Run Script`를 추가합니다.
  - 프로젝트 직속으로 empty 파일을 만들고 파일명을 `.swiftlint.yml`로 설정합니다.
  - [SwiftLint Rule Directory](https://realm.github.io/SwiftLint/rule-directory.html)를 확인해서, 원하는 옵션을 추가해줍니다.

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156407115-ef3ae2b6-a488-4a3b-8f81-c44f72f7646a.png" width="50%"></p>

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156407140-79e8b335-aeb4-4b26-8acc-9261d06a104c.png" width="100%"></p>

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156407173-5fda4a53-e4cc-4d42-8371-9a5d5b06a674.png" width="100%"></p>

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156408060-a8ca8935-bea8-48b2-b8c3-23d433adc73a.png" width="40%"></p>

</details>

<details>
<summary><h3>6️⃣ Google Firebase API Key 노출에 대해서</h3></summary>

- Firebase 연동을 위해 추가한 `GoogleService-Info.plist` 파일을 깃헙에 푸시하고 잠시 후에 [GitGuardian](https://www.gitguardian.com/) 이라는 곳에서 이메일을 받았습니다.
- 민감 정보인 `Google API Key`가 public repo 에 노출되었다는 경고였는데요.
리뷰어와 논의하고 구글링을 해본 결과, 굳이 숨겨줄 필요가 없는 것으로 판단했습니다.
  - 📄 참고 문서 -> [Firebase API Key를 공개하는 것이 안전합니까?](https://haranglog.tistory.com/25)

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/156119042-3dd7ccfe-f2f2-410f-b410-03a720c44906.png" width="70%"></p>

</details>
