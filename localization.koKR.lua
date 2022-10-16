if GetLocale() ~= "koKR" then return end
_G.PlexusBuffIconsLocale = {
    ["Buff Icons"] = "버프 아이콘",

    ["Show Buff instead of Debuff"] = "디버프 대신 버프 표시",
    ["If selected, the icons will present unit buffs instead of debuffs."] = "선택시, 아이콘의 디버프 대신 유닛 버프를 표시합니다.",

    ["Only Mine"] = "내 버프만",

    ["Only castable/removable"] = "내가 시전 가능 및 제거 가능 (디)버프만",
    ["If selected, only shows the buffs you can cast or the debuffs you can remove."] = "선택하면 내가 시전할 수 있는 버프/디버프나 제거할 수 있는 디버프만 표시합니다.",

    ["Show cooldown on icon"] = "아이콘에 쿨타임 표시",

    ["Show Cooldown text"] = "쿨타임 텍스트 표시",
    ["If disabled, OmniCC will not add texts on the icons."] = "끄면 OmniCC에서도 아이콘에 텍스트를 표시하지 않습니다.",

    ["Icons Size"] = "아이콘 크기",
    ["Size for each buff icon"] = "각 버프 아이콘의 크기를 설정합니다.",

    ["Alpha"] = "투명도",
    ["Alpha value for each buff icon"] = "각 버프 아이콘의 투명도를 설정합니다.",

    ["Offset X"] = "X 간격",
    ["X-axis offset from the selected anchor point, minus value to move inside."] = "지시기에서 움직일 선택된 앵커 위치로 부터의 X-각격을 설정합니다.",

    ["Offset Y"] = "Y 간격",
    ["Y-axis offset from the selected anchor point, minus value to move inside."] = "지시기에서 움직일 선택된 앵커 위치로 부터의 Y-간격을 설정합니다.",

    ["Icon Numbers"] = "아이콘 갯수",
    ["Max icons to show."] = "표시할 최대 아이콘 갯수를 설정합니다.",

    ["Icons Per Row"] = "아이콘 줄 수",
    ["Sperate icons in several rows."] = "아이콘을 표시할 줄수를 설정합니다.",

    ["Orientation of Icon"] = "아이콘 정렬",
    ["Set icons list orientation."] = "세트 아이콘을 표시 방향을 설정합니다.",

    ["Anchor Point"] = "앵커 위치",
    ["Anchor point of the first icon."] = "첫번째 아이콘의 위치를 지정합니다.",

    ["Buffs/Debuffs Never Shown"] = "숨길 버프/디버프",
    ["Buff or Debuff names never to show, seperated by ','"] = "표시하지 않을 버프나 디버프 이름을 입력하세요. ',' 기호로 구분",

    ["VERTICAL"] = "세로",
    ["HORIZONTAL"] = "가로",

    ["TOPRIGHT"] = "우측 상단",
    ["TOPLEFT"] = "좌측 상단",
    ["BOTTOMLEFT"] = "좌측 하단",
    ["BOTTOMRIGHT"] = "우측 하단",
}