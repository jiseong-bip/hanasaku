/// none : 아무 UI없음 (메인화면에서 사용)
/// CenterButtonOnly : 중앙 재생/정지 토글버튼
/// BottomBarOnly : 하단 indicator, 재생/정지 토글, 사운드 토글
/// Full = CenterButtonOnly + BottomBarOnly
enum VideoOption { none, centerButtonOnly, bottomBarOnly, full }

/// 버튼 토글용
enum PlayerButtonState { stopped, playing, paused }