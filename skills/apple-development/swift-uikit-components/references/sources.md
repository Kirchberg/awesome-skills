# Primary sources

Last reviewed: 2026-08-13.

Use current Apple documentation and the generated SDK interface from the target
toolchain as the authority for API availability. WWDC26 material describes the
current prerelease platform
generation as of this review; gate those APIs and behaviors explicitly, and
recheck them before shipping. Archived documentation remains useful for durable
concepts but does not establish current availability.

## UIKit foundations and component state

- [UIKit](https://developer.apple.com/documentation/uikit)
- [About app development with UIKit](https://developer.apple.com/documentation/uikit/about-app-development-with-uikit)
- [Views and controls](https://developer.apple.com/documentation/uikit/views-and-controls)
- [Configurations](https://developer.apple.com/documentation/uikit/configurations)
- [UIContentConfiguration](https://developer.apple.com/documentation/uikit/uicontentconfiguration)
- [UIButton.Configuration](https://developer.apple.com/documentation/uikit/uibutton/configuration-swift.struct)
- [UIAction](https://developer.apple.com/documentation/uikit/uiaction)
- [UIMenu](https://developer.apple.com/documentation/uikit/uimenu)
- [UIContentUnavailableConfiguration](https://developer.apple.com/documentation/uikit/uicontentunavailableconfiguration-swift.struct)
- [Meet the UIKit button system](https://developer.apple.com/videos/play/wwdc2021/10064/)
- [Build with iOS pickers, menus and actions](https://developer.apple.com/videos/play/wwdc2020/10052/)

## Layout, traits, and controllers

- [Displaying and managing views with a view controller](https://developer.apple.com/documentation/uikit/displaying-and-managing-views-with-a-view-controller)
- [Creating a custom container view controller](https://developer.apple.com/documentation/uikit/view_controllers/creating_a_custom_container_view_controller)
- [Showing and hiding view controllers](https://developer.apple.com/documentation/uikit/showing-and-hiding-view-controllers)
- [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller)
- [UIPopoverPresentationController](https://developer.apple.com/documentation/uikit/uipopoverpresentationcontroller)
- [Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/)
- [Adapting your app when traits change](https://developer.apple.com/documentation/uikit/adapting-your-app-when-traits-change)
- [Automatic trait tracking](https://developer.apple.com/documentation/uikit/automatic-trait-tracking)
- [Updating views automatically with observation tracking in UIKit](https://developer.apple.com/documentation/uikit/updating-views-automatically-with-observation-tracking-in-uikit)
- [UIKeyboardLayoutGuide](https://developer.apple.com/documentation/uikit/uikeyboardlayoutguide)
- [Make your UIKit app more flexible](https://developer.apple.com/videos/play/wwdc2025/282/)
- [Modernize your UIKit app](https://developer.apple.com/videos/play/wwdc2026/278/)

## Lists and collections

- [Implementing modern collection views](https://developer.apple.com/documentation/uikit/implementing-modern-collection-views)
- [Updating collection views using diffable data sources](https://developer.apple.com/documentation/uikit/updating-collection-views-using-diffable-data-sources)
- [UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout)
- [UICollectionView.CellRegistration](https://developer.apple.com/documentation/uikit/uicollectionview/cellregistration)
- [UICollectionLayoutListConfiguration](https://developer.apple.com/documentation/uikit/uicollectionlayoutlistconfiguration-swift.struct)
- [Building high-performance lists and collection views](https://developer.apple.com/documentation/uikit/building-high-performance-lists-and-collection-views)
- [Advances in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10097/)
- [Lists in UICollectionView](https://developer.apple.com/videos/play/wwdc2020/10026/)
- [Modern cell configuration](https://developer.apple.com/videos/play/wwdc2020/10027/)
- [Advances in UI Data Sources](https://developer.apple.com/videos/play/wwdc2019/220/)
- [Make blazing fast lists and collection views](https://developer.apple.com/videos/play/wwdc2021/10252/)

## SwiftUI interoperability and evidence

- [UIHostingController](https://developer.apple.com/documentation/swiftui/uihostingcontroller)
- [UIHostingConfiguration](https://developer.apple.com/documentation/swiftui/uihostingconfiguration)
- [Use SwiftUI with UIKit](https://developer.apple.com/videos/play/wwdc2022/10072/)
- [Use SwiftUI with AppKit and UIKit](https://developer.apple.com/videos/play/wwdc2026/272/)
- [Understanding hangs in your app](https://developer.apple.com/documentation/xcode/understanding-hangs-in-your-app)
- [Understanding hitches in your app](https://developer.apple.com/documentation/xcode/understanding-hitches-in-your-app)
- [Analyze hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)
- [Accessibility for UIKit](https://developer.apple.com/documentation/uikit/accessibility-for-uikit)
