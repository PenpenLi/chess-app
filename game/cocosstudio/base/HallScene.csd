<GameFile>
  <PropertyGroup Name="HallScene" Type="Scene" ID="caeaa672-a022-42cd-9635-afc30af9f4f8" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000">
        <Timeline ActionTag="-1405023310" Property="Position">
          <PointFrame FrameIndex="0" X="1136.0000" Y="0.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-1405023310" Property="Scale">
          <ScaleFrame FrameIndex="0" X="1.0000" Y="1.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
        <Timeline ActionTag="-1405023310" Property="RotationSkew">
          <ScaleFrame FrameIndex="0" X="0.0000" Y="0.0000">
            <EasingData Type="0" />
          </ScaleFrame>
        </Timeline>
      </Animation>
      <ObjectData Name="Scene" Tag="4" ctype="GameNodeObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="bg_img" ActionTag="-1818101270" Tag="10" IconVisible="False" LeftMargin="-125.0000" RightMargin="-125.0000" LeftEage="15" RightEage="15" TopEage="15" BottomEage="15" Scale9OriginX="15" Scale9OriginY="15" Scale9Width="1250" Scale9Height="561" ctype="ImageViewObjectData">
            <Size X="1386.0000" Y="640.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0000" Y="320.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.5000" />
            <PreSize X="1.2201" Y="1.0000" />
            <FileData Type="Normal" Path="base/images/main_layer/bg.jpg" Plist="" />
          </AbstractNodeData>
          <AbstractNodeData Name="particle_node" ActionTag="1253635554" Tag="120" IconVisible="True" LeftMargin="568.0000" RightMargin="568.0000" BottomMargin="640.0000" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <Children>
              <AbstractNodeData Name="snow_1_particle" ActionTag="-667440631" Tag="72" IconVisible="True" ctype="ParticleObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="base/animation/particle/snow.plist" Plist="" />
                <BlendFunc Src="770" Dst="1" />
              </AbstractNodeData>
              <AbstractNodeData Name="fireworks_node1" ActionTag="1107514917" Tag="91" IconVisible="True" LeftMargin="-240.0000" RightMargin="240.0000" TopMargin="132.0000" BottomMargin="-132.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="-240.0000" Y="-132.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="fireworks_node2" ActionTag="-1002350879" Tag="92" IconVisible="True" LeftMargin="204.0000" RightMargin="-204.0000" TopMargin="86.0000" BottomMargin="-86.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="204.0000" Y="-86.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="568.0000" Y="640.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="1.0000" />
            <PreSize X="0.0000" Y="0.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="center_panel" ActionTag="-281757524" Tag="128" IconVisible="False" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <Children>
              <AbstractNodeData Name="scrollview" ActionTag="-105445791" Tag="77" IconVisible="False" HorizontalEdge="RightEdge" LeftMargin="323.0000" RightMargin="-323.0000" TopMargin="100.0000" BottomMargin="100.0000" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" IsBounceEnabled="True" ScrollDirectionType="Horizontal" ctype="ScrollViewObjectData">
                <Size X="1136.0000" Y="440.0000" />
                <Children>
                  <AbstractNodeData Name="right_panel" ActionTag="156998092" Tag="130" IconVisible="False" HorizontalEdge="RightEdge" RightMargin="1000.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                    <Size X="1136.0000" Y="440.0000" />
                    <AnchorPoint />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.5318" Y="1.0000" />
                    <SingleColor A="255" R="72" G="143" B="221" />
                    <FirstColor A="255" R="150" G="200" B="255" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="323.0000" Y="100.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2843" Y="0.1563" />
                <PreSize X="1.0000" Y="0.6875" />
                <SingleColor A="255" R="255" G="150" B="100" />
                <FirstColor A="255" R="255" G="150" B="100" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
                <InnerNodeSize Width="2136" Height="440" />
              </AbstractNodeData>
              <AbstractNodeData Name="arrow_left_btn" Visible="False" ActionTag="-1022021655" Tag="682" IconVisible="False" LeftMargin="-47.0000" RightMargin="1116.0000" TopMargin="291.0000" BottomMargin="255.0000" TouchEnable="True" FlipX="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="37" Scale9Height="72" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="67.0000" Y="94.0000" />
                <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
                <Position X="20.0000" Y="302.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.0176" Y="0.4719" />
                <PreSize X="0.0590" Y="0.1469" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="base/images/main_layer/arrow_btn.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="arrow_right_btn" Visible="False" ActionTag="-718330238" Tag="683" IconVisible="False" LeftMargin="1069.0000" TopMargin="291.0000" BottomMargin="255.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="37" Scale9Height="72" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="67.0000" Y="94.0000" />
                <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
                <Position X="1136.0000" Y="302.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="1.0000" Y="0.4719" />
                <PreSize X="0.0590" Y="0.1469" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="base/images/main_layer/arrow_btn.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="left_panel" ActionTag="219665668" Tag="129" IconVisible="False" RightMargin="813.0000" TopMargin="200.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="323.0000" Y="440.0000" />
                <Children>
                  <AbstractNodeData Name="pageview" ActionTag="1604536163" Tag="132" IconVisible="False" TopMargin="-100.0000" BottomMargin="100.0000" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ScrollDirectionType="0" ctype="PageViewObjectData">
                    <Size X="323.0000" Y="440.0000" />
                    <AnchorPoint />
                    <Position Y="100.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition Y="0.2273" />
                    <PreSize X="1.0000" Y="1.0000" />
                    <SingleColor A="255" R="150" G="150" B="100" />
                    <FirstColor A="255" R="150" G="150" B="100" />
                    <EndColor A="255" R="255" G="255" B="255" />
                    <ColorVector ScaleY="1.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="dot_1" ActionTag="-1577498976" Tag="800" IconVisible="False" LeftMargin="141.0000" RightMargin="168.0000" TopMargin="328.0000" BottomMargin="98.0000" LeftEage="4" RightEage="4" TopEage="4" BottomEage="4" Scale9OriginX="4" Scale9OriginY="4" Scale9Width="6" Scale9Height="6" ctype="ImageViewObjectData">
                    <Size X="14.0000" Y="14.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="148.0000" Y="105.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4582" Y="0.2386" />
                    <PreSize X="0.0433" Y="0.0318" />
                    <FileData Type="Normal" Path="base/images/main_layer/dot2.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="dot_2" ActionTag="1986323228" Tag="801" IconVisible="False" LeftMargin="159.0000" RightMargin="150.0000" TopMargin="328.0000" BottomMargin="98.0000" LeftEage="4" RightEage="4" TopEage="4" BottomEage="4" Scale9OriginX="4" Scale9OriginY="4" Scale9Width="6" Scale9Height="6" ctype="ImageViewObjectData">
                    <Size X="14.0000" Y="14.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="166.0000" Y="105.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5139" Y="0.2386" />
                    <PreSize X="0.0433" Y="0.0318" />
                    <FileData Type="Normal" Path="base/images/main_layer/dot1.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="dot_3" ActionTag="1651772888" Tag="178" IconVisible="False" LeftMargin="177.0000" RightMargin="132.0000" TopMargin="328.0000" BottomMargin="98.0000" LeftEage="4" RightEage="4" TopEage="4" BottomEage="4" Scale9OriginX="4" Scale9OriginY="4" Scale9Width="6" Scale9Height="6" ctype="ImageViewObjectData">
                    <Size X="14.0000" Y="14.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="184.0000" Y="105.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5697" Y="0.2386" />
                    <PreSize X="0.0433" Y="0.0318" />
                    <FileData Type="Normal" Path="base/images/main_layer/dot2.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.2843" Y="0.6875" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" />
            <Position X="568.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="top_panel" ActionTag="1487237454" Tag="65" IconVisible="False" BottomMargin="540.0000" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1136.0000" Y="100.0000" />
            <Children>
              <AbstractNodeData Name="Image_1" ActionTag="1675863197" Tag="85" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="-125.0000" RightMargin="-125.0000" BottomMargin="9.0000" LeftEage="422" RightEage="422" TopEage="30" BottomEage="30" Scale9OriginX="422" Scale9OriginY="30" Scale9Width="436" Scale9Height="31" ctype="ImageViewObjectData">
                <Size X="1386.0000" Y="91.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="568.0000" Y="54.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5450" />
                <PreSize X="1.2201" Y="0.9100" />
                <FileData Type="Normal" Path="base/images/main_layer/Hall_TopBg.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_1_0" ActionTag="754474999" Tag="86" RotationSkewX="180.0000" RotationSkewY="180.0000" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="-184.5000" RightMargin="-164.5000" TopMargin="561.5000" BottomMargin="-552.5000" LeftEage="422" RightEage="422" TopEage="30" BottomEage="30" Scale9OriginX="422" Scale9OriginY="30" Scale9Width="436" Scale9Height="31" ctype="ImageViewObjectData">
                <Size X="1485.0000" Y="91.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="558.0000" Y="-507.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4912" Y="-5.0700" />
                <PreSize X="1.3072" Y="0.9100" />
                <FileData Type="Normal" Path="base/images/main_layer/Hall_TopBg.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="denglong_node" ActionTag="1047863312" Tag="89" IconVisible="True" LeftMargin="1030.0000" RightMargin="106.0000" TopMargin="18.0000" BottomMargin="82.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="1030.0000" Y="82.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9067" Y="0.8200" />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="head_node" ActionTag="653635798" Tag="108" IconVisible="True" LeftMargin="75.0000" RightMargin="1061.0000" TopMargin="50.0000" BottomMargin="50.0000" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="label" ActionTag="-475796977" Tag="70" IconVisible="False" LeftMargin="55.4950" RightMargin="-151.4950" TopMargin="-37.6074" BottomMargin="13.6074" FontSize="24" LabelText="大吉大利" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="96.0000" Y="24.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="55.4950" Y="25.6074" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FontResource Type="Default" Path="" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="name_img" ActionTag="105128078" Alpha="0" Tag="66" IconVisible="False" LeftMargin="38.0000" RightMargin="-181.0000" TopMargin="-16.5000" BottomMargin="-16.5000" Scale9Enable="True" LeftEage="110" RightEage="20" Scale9OriginX="110" Scale9Width="13" Scale9Height="33" ctype="ImageViewObjectData">
                    <Size X="143.0000" Y="33.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="38.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="base/images/main_layer/img_dt_idbg.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="head_img" ActionTag="1577545754" Tag="67" IconVisible="False" LeftMargin="-47.0000" RightMargin="-47.0000" TopMargin="-47.0000" BottomMargin="-47.0000" LeftEage="44" RightEage="44" TopEage="45" BottomEage="45" Scale9OriginX="44" Scale9OriginY="45" Scale9Width="6" Scale9Height="4" ctype="ImageViewObjectData">
                    <Size X="94.0000" Y="94.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position />
                    <Scale ScaleX="0.7900" ScaleY="0.7900" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <FileData Type="Normal" Path="common/head/head_08.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="node_headBg" ActionTag="-332164595" Tag="118" IconVisible="True" TopMargin="-2.0000" BottomMargin="2.0000" ctype="SingleNodeObjectData">
                    <Size X="0.0000" Y="0.0000" />
                    <AnchorPoint />
                    <Position Y="2.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="head_btn" ActionTag="-1895562035" Tag="69" IconVisible="False" LeftMargin="-35.0000" RightMargin="-35.0000" TopMargin="-35.5000" BottomMargin="-35.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="-15" Scale9OriginY="-4" Scale9Width="30" Scale9Height="8" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="70.0000" Y="71.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="75.0000" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.0660" Y="0.5000" />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="blance_node" ActionTag="-560987305" Tag="109" IconVisible="True" LeftMargin="119.0935" RightMargin="1016.9065" TopMargin="55.6100" BottomMargin="44.3900" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <Children>
                  <AbstractNodeData Name="recharge_btn2" ActionTag="289477404" Tag="72" IconVisible="False" RightMargin="-184.0000" TopMargin="-20.0000" BottomMargin="-28.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="154" Scale9Height="26" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="184.0000" Y="48.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position Y="-4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <PressedFileData Type="Normal" Path="base/images/main_layer/icon_add.png" Plist="" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_add.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="blance_label" ActionTag="1887350247" Tag="71" IconVisible="False" LeftMargin="60.0000" RightMargin="-157.0000" TopMargin="-4.0000" BottomMargin="-26.0000" LabelText="78.34" ctype="TextBMFontObjectData">
                    <Size X="97.0000" Y="30.0000" />
                    <AnchorPoint ScaleY="0.5000" />
                    <Position X="60.0000" Y="-11.0000" />
                    <Scale ScaleX="0.7500" ScaleY="0.7500" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <LabelBMFontFile_CNB Type="Normal" Path="base/font/dt_jinbi_num.fnt" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="recharge_btn" ActionTag="283977477" Tag="73" IconVisible="False" LeftMargin="145.5229" RightMargin="-236.5229" TopMargin="-23.5100" BottomMargin="-46.4900" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="61" Scale9Height="62" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="91.0000" Y="70.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="191.0229" Y="-11.4900" />
                    <Scale ScaleX="0.7000" ScaleY="0.7000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition />
                    <PreSize X="0.0000" Y="0.0000" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_add_btn.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="119.0935" Y="44.3900" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.1048" Y="0.4439" />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="huodong_btn" ActionTag="-118616404" Tag="92" IconVisible="False" LeftMargin="805.5000" RightMargin="235.5000" TopMargin="11.5000" BottomMargin="3.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="40" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="95.0000" Y="85.0000" />
                <Children>
                  <AbstractNodeData Name="dot_img" ActionTag="-2089627471" Tag="93" IconVisible="False" LeftMargin="61.0000" TopMargin="2.0000" BottomMargin="49.0000" LeftEage="10" RightEage="10" TopEage="10" BottomEage="10" Scale9OriginX="10" Scale9OriginY="10" Scale9Width="14" Scale9Height="14" ctype="ImageViewObjectData">
                    <Size X="34.0000" Y="34.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="78.0000" Y="66.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.8211" Y="0.7765" />
                    <PreSize X="0.3579" Y="0.4000" />
                    <FileData Type="Normal" Path="base/images/main_layer/red_point.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="853.0000" Y="46.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.7509" Y="0.4600" />
                <PreSize X="0.0836" Y="0.8500" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="base/images/huodong_popup/icon_huodong.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="announce_btn" ActionTag="1060681775" Tag="74" IconVisible="False" LeftMargin="908.5000" RightMargin="136.5000" TopMargin="4.5000" BottomMargin="4.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="48" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="91.0000" Y="91.0000" />
                <Children>
                  <AbstractNodeData Name="dot_img" ActionTag="-1830841941" Tag="75" IconVisible="False" LeftMargin="61.0000" RightMargin="-4.0000" TopMargin="8.0000" BottomMargin="49.0000" LeftEage="10" RightEage="10" TopEage="10" BottomEage="10" Scale9OriginX="10" Scale9OriginY="10" Scale9Width="14" Scale9Height="14" ctype="ImageViewObjectData">
                    <Size X="34.0000" Y="34.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="78.0000" Y="66.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.8571" Y="0.7253" />
                    <PreSize X="0.3736" Y="0.3736" />
                    <FileData Type="Normal" Path="base/images/main_layer/red_point.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="954.0000" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.8398" Y="0.5000" />
                <PreSize X="0.0801" Y="0.9100" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="base/images/main_layer/icon_news.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="service_btn" ActionTag="667474021" Tag="76" IconVisible="False" LeftMargin="1009.5000" RightMargin="35.5000" TopMargin="4.5000" BottomMargin="4.5000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="40" Scale9Height="54" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="91.0000" Y="91.0000" />
                <Children>
                  <AbstractNodeData Name="dot_img" ActionTag="373422332" Tag="77" IconVisible="False" LeftMargin="61.0000" RightMargin="-4.0000" TopMargin="8.0000" BottomMargin="49.0000" LeftEage="10" RightEage="10" TopEage="10" BottomEage="10" Scale9OriginX="10" Scale9OriginY="10" Scale9Width="14" Scale9Height="14" ctype="ImageViewObjectData">
                    <Size X="34.0000" Y="34.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="78.0000" Y="66.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.8571" Y="0.7253" />
                    <PreSize X="0.3736" Y="0.3736" />
                    <FileData Type="Normal" Path="base/images/main_layer/red_point.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="1055.0000" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9287" Y="0.5000" />
                <PreSize X="0.0801" Y="0.9100" />
                <TextColor A="255" R="65" G="65" B="70" />
                <NormalFileData Type="Normal" Path="base/images/main_layer/icon_service.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
              <AbstractNodeData Name="node_gameHallLogo" ActionTag="635113117" Tag="1041" IconVisible="True" LeftMargin="580.0000" RightMargin="556.0000" TopMargin="49.0505" BottomMargin="50.9495" ctype="SingleNodeObjectData">
                <Size X="0.0000" Y="0.0000" />
                <AnchorPoint />
                <Position X="580.0000" Y="50.9495" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5106" Y="0.5095" />
                <PreSize X="0.0000" Y="0.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_1_1_0" ActionTag="-836299733" Tag="89" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="409.4986" RightMargin="663.5014" TopMargin="20.9973" BottomMargin="16.0027" LeftEage="20" RightEage="20" TopEage="30" BottomEage="30" Scale9OriginX="20" Scale9OriginY="30" Scale9Width="23" Scale9Height="3" ctype="ImageViewObjectData">
                <Size X="63.0000" Y="63.0000" />
                <AnchorPoint ScaleX="-2.7122" ScaleY="0.8819" />
                <Position X="238.6300" Y="71.5624" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.2101" Y="0.7156" />
                <PreSize X="0.0555" Y="0.6300" />
                <FileData Type="Normal" Path="base/images/main_layer/NY_fu.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="Image_1_1_1" ActionTag="-1561479996" Tag="91" IconVisible="False" HorizontalEdge="LeftEdge" VerticalEdge="TopEdge" LeftMargin="694.5000" RightMargin="378.5000" TopMargin="20.0000" BottomMargin="17.0000" LeftEage="20" RightEage="20" TopEage="30" BottomEage="30" Scale9OriginX="20" Scale9OriginY="30" Scale9Width="23" Scale9Height="3" ctype="ImageViewObjectData">
                <Size X="63.0000" Y="63.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="726.0000" Y="48.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.6391" Y="0.4850" />
                <PreSize X="0.0555" Y="0.6300" />
                <FileData Type="Normal" Path="base/images/main_layer/NY_fu.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleY="1.0000" />
            <Position Y="640.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition Y="1.0000" />
            <PreSize X="1.0000" Y="0.1563" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="room_panel" ActionTag="1195516269" Tag="143" IconVisible="False" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <Children>
              <AbstractNodeData Name="top_panel" ActionTag="-1243119153" Tag="163" IconVisible="False" BottomMargin="540.0000" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="1136.0000" Y="100.0000" />
                <Children>
                  <AbstractNodeData Name="title_node" ActionTag="1285580082" Tag="120" IconVisible="True" LeftMargin="1090.0000" RightMargin="46.0000" TopMargin="50.0000" BottomMargin="50.0000" ctype="SingleNodeObjectData">
                    <Size X="0.0000" Y="0.0000" />
                    <Children>
                      <AbstractNodeData Name="title_img" ActionTag="242370786" Tag="76" IconVisible="False" LeftMargin="-247.0000" TopMargin="-31.0000" BottomMargin="-31.0000" ctype="SpriteObjectData">
                        <Size X="247.0000" Y="62.0000" />
                        <AnchorPoint ScaleX="1.0000" ScaleY="0.5000" />
                        <Position />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition />
                        <PreSize X="0.0000" Y="0.0000" />
                        <FileData Type="Normal" Path="base/images/room_layer/brnn_title.png" Plist="" />
                        <BlendFunc Src="1" Dst="771" />
                      </AbstractNodeData>
                      <AbstractNodeData Name="help_btn" ActionTag="-1052209601" VisibleForFrame="False" Tag="119" IconVisible="False" LeftMargin="-0.5000" RightMargin="-52.5000" TopMargin="-21.5000" BottomMargin="-29.5000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="23" Scale9Height="29" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                        <Size X="53.0000" Y="51.0000" />
                        <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                        <Position X="26.0000" Y="-4.0000" />
                        <Scale ScaleX="1.0000" ScaleY="1.0000" />
                        <CColor A="255" R="255" G="255" B="255" />
                        <PrePosition />
                        <PreSize X="0.0000" Y="0.0000" />
                        <TextColor A="255" R="65" G="65" B="70" />
                        <NormalFileData Type="Normal" Path="base/images/rank_popup/rule_bt.png" Plist="" />
                        <OutlineColor A="255" R="255" G="0" B="0" />
                        <ShadowColor A="255" R="110" G="110" B="110" />
                      </AbstractNodeData>
                    </Children>
                    <AnchorPoint />
                    <Position X="1090.0000" Y="50.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.9595" Y="0.5000" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="close_btn" ActionTag="1621486680" Tag="165" IconVisible="False" LeftMargin="25.5000" RightMargin="1021.5000" TopMargin="96.5000" BottomMargin="-67.5000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="59" Scale9Height="49" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="89.0000" Y="71.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="70.0000" Y="-32.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.0616" Y="-0.3200" />
                    <PreSize X="0.0783" Y="0.7100" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/room_layer/btn_back.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleY="1.0000" />
                <Position Y="640.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition Y="1.0000" />
                <PreSize X="1.0000" Y="0.1563" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="list_panel" ActionTag="-873946003" Tag="162" IconVisible="False" TopMargin="182.0000" BottomMargin="122.0000" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="1136.0000" Y="336.0000" />
                <AnchorPoint ScaleY="0.5000" />
                <Position Y="290.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition Y="0.4531" />
                <PreSize X="1.0000" Y="0.5250" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" />
            <Position X="568.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="bottom_panel" ActionTag="1796689932" Tag="78" IconVisible="False" TopMargin="545.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1136.0000" Y="95.0000" />
            <Children>
              <AbstractNodeData Name="bottom_img" Visible="False" ActionTag="20896617" Tag="79" IconVisible="False" TopMargin="234.0000" BottomMargin="-200.0000" LeftEage="376" RightEage="376" TopEage="20" BottomEage="20" Scale9OriginX="376" Scale9OriginY="20" Scale9Width="384" Scale9Height="21" ctype="ImageViewObjectData">
                <Size X="1136.0000" Y="61.0000" />
                <AnchorPoint ScaleX="0.5000" />
                <Position X="568.0000" Y="-200.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="-2.1053" />
                <PreSize X="1.0000" Y="0.6421" />
                <FileData Type="Normal" Path="base/images/main_layer/bottom_bar.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="xue_img" ActionTag="1416335988" Tag="87" IconVisible="False" LeftMargin="143.0000" RightMargin="277.0000" TopMargin="229.5000" BottomMargin="-185.5000" LeftEage="236" RightEage="236" TopEage="16" BottomEage="16" Scale9OriginX="236" Scale9OriginY="16" Scale9Width="244" Scale9Height="19" ctype="ImageViewObjectData">
                <Size X="716.0000" Y="51.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="501.0000" Y="-160.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4410" Y="-1.6842" />
                <PreSize X="0.6303" Y="0.5368" />
                <FileData Type="Normal" Path="base/images/main_layer/xue2.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="rank_panel" ActionTag="-955312943" Tag="80" IconVisible="False" RightMargin="951.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="185.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="rank_img" ActionTag="157785498" VisibleForFrame="False" Tag="81" IconVisible="False" LeftMargin="61.0000" RightMargin="29.0000" TopMargin="-33.0000" BottomMargin="4.0000" LeftEage="31" RightEage="31" TopEage="22" BottomEage="22" Scale9OriginX="31" Scale9OriginY="22" Scale9Width="26" Scale9Height="46" ctype="ImageViewObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="108.5000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5865" Y="0.0571" />
                    <PreSize X="0.5135" Y="1.4143" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_rank.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="divider_img" ActionTag="-1972180149" VisibleForFrame="False" Tag="82" IconVisible="False" LeftMargin="181.0000" RightMargin="-3.0000" TopMargin="-3.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="3" Scale9Height="25" ctype="ImageViewObjectData">
                    <Size X="7.0000" Y="73.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="188.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.0162" />
                    <PreSize X="0.0378" Y="1.0429" />
                    <FileData Type="Normal" Path="base/images/main_layer/divider.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="rank_btn" ActionTag="-1074141609" Tag="83" IconVisible="False" LeftMargin="61.0000" RightMargin="29.0000" TopMargin="-33.0000" BottomMargin="4.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="58" Scale9Height="82" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="108.5000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5865" Y="0.0571" />
                    <PreSize X="0.5135" Y="1.4143" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_rank.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.1629" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="bank_panel" ActionTag="1383895483" Tag="84" IconVisible="False" LeftMargin="351.0000" RightMargin="610.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="175.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="bank_img" ActionTag="587005678" VisibleForFrame="False" Tag="85" IconVisible="False" LeftMargin="15.5000" RightMargin="64.5000" TopMargin="-33.0000" BottomMargin="4.0000" LeftEage="54" RightEage="54" TopEage="22" BottomEage="22" Scale9OriginX="33" Scale9OriginY="22" Scale9Width="21" Scale9Height="43" ctype="ImageViewObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="63.0000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.3600" Y="0.0571" />
                    <PreSize X="0.5429" Y="1.4143" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_bank.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="divider_img" ActionTag="686017542" VisibleForFrame="False" Tag="86" IconVisible="False" LeftMargin="171.5000" RightMargin="-3.5000" TopMargin="-3.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="3" Scale9Height="25" ctype="ImageViewObjectData">
                    <Size X="7.0000" Y="73.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="178.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.0200" />
                    <PreSize X="0.0400" Y="1.0429" />
                    <FileData Type="Normal" Path="base/images/main_layer/divider.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="bank_btn" ActionTag="-681853048" Tag="87" IconVisible="False" LeftMargin="15.5000" RightMargin="64.5000" TopMargin="-33.0000" BottomMargin="4.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="57" Scale9Height="79" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="63.0000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.3600" Y="0.0571" />
                    <PreSize X="0.5429" Y="1.4143" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_bank.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="351.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.3090" />
                <PreSize X="0.1540" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="exchange_panel" ActionTag="-1394630923" Tag="88" IconVisible="False" LeftMargin="181.0000" RightMargin="785.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="170.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="exchange_img" ActionTag="-647092671" VisibleForFrame="False" Tag="89" IconVisible="False" LeftMargin="37.5000" RightMargin="37.5000" TopMargin="-33.0000" BottomMargin="4.0000" LeftEage="54" RightEage="54" TopEage="22" BottomEage="22" Scale9OriginX="30" Scale9OriginY="22" Scale9Width="24" Scale9Height="44" ctype="ImageViewObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="85.0000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.0571" />
                    <PreSize X="0.5588" Y="1.4143" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_exchange.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="exchange_img2" ActionTag="-544309391" VisibleForFrame="False" Tag="92" IconVisible="False" LeftMargin="13.5000" RightMargin="99.5000" TopMargin="9.5000" BottomMargin="3.5000" LeftEage="18" RightEage="18" TopEage="22" BottomEage="22" Scale9OriginX="18" Scale9OriginY="22" Scale9Width="21" Scale9Height="13" ctype="ImageViewObjectData">
                    <Size X="57.0000" Y="57.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="42.0000" Y="32.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2471" Y="0.4571" />
                    <PreSize X="0.3353" Y="0.8143" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_exchange_2.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="divider_img" ActionTag="1849900694" VisibleForFrame="False" Tag="90" IconVisible="False" LeftMargin="164.0000" RightMargin="-1.0000" TopMargin="-3.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="3" Scale9Height="25" ctype="ImageViewObjectData">
                    <Size X="7.0000" Y="73.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="171.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.0059" />
                    <PreSize X="0.0412" Y="1.0429" />
                    <FileData Type="Normal" Path="base/images/main_layer/divider.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="exchange_btn" ActionTag="-751622857" Tag="91" IconVisible="False" LeftMargin="37.5000" RightMargin="37.5000" TopMargin="-33.0000" BottomMargin="4.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="54" Scale9Height="80" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="95.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="85.0000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.0571" />
                    <PreSize X="0.5588" Y="1.4143" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_exchange.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="181.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.1593" />
                <PreSize X="0.1496" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="money_panel" ActionTag="-599925759" Tag="93" IconVisible="False" LeftMargin="692.0000" RightMargin="282.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="162.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="skeleton_node" ActionTag="1176308914" Tag="124" IconVisible="True" LeftMargin="81.0000" RightMargin="81.0000" TopMargin="35.0000" BottomMargin="35.0000" ctype="SingleNodeObjectData">
                    <Size X="0.0000" Y="0.0000" />
                    <AnchorPoint />
                    <Position X="81.0000" Y="35.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="divider_img" ActionTag="1337999395" VisibleForFrame="False" Tag="96" IconVisible="False" LeftMargin="158.5000" RightMargin="-3.5000" TopMargin="-3.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="3" Scale9Height="25" ctype="ImageViewObjectData">
                    <Size X="7.0000" Y="73.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="165.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.0216" />
                    <PreSize X="0.0432" Y="1.0429" />
                    <FileData Type="Normal" Path="base/images/main_layer/divider.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="money_btn" ActionTag="1059224264" Tag="97" IconVisible="False" LeftMargin="-11.5000" RightMargin="59.5000" TopMargin="-33.0000" BottomMargin="4.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="75" Scale9Height="85" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="114.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="102.5000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.6327" Y="0.0571" />
                    <PreSize X="0.7037" Y="1.4143" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/ZCSJ_00.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="money_img" ActionTag="1602849307" VisibleForFrame="False" Tag="534" IconVisible="False" LeftMargin="-11.5000" RightMargin="59.5000" TopMargin="-33.0000" BottomMargin="4.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="101" Scale9Height="45" ctype="ImageViewObjectData">
                    <Size X="114.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="102.5000" Y="4.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.6327" Y="0.0571" />
                    <PreSize X="0.7037" Y="1.4143" />
                    <FileData Type="Normal" Path="base/images/main_layer/ZCSJ_00.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="692.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.6092" />
                <PreSize X="0.1426" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="proxy_panel" ActionTag="1451469194" Tag="99" IconVisible="False" LeftMargin="530.0000" RightMargin="436.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="170.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="proxy_img" ActionTag="348744041" VisibleForFrame="False" Tag="100" IconVisible="False" LeftMargin="-15.0000" RightMargin="61.0000" TopMargin="-34.0000" BottomMargin="5.0000" LeftEage="54" RightEage="54" TopEage="22" BottomEage="22" Scale9OriginX="54" Scale9OriginY="22" Scale9Width="2" Scale9Height="54" ctype="ImageViewObjectData">
                    <Size X="124.0000" Y="99.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="47.0000" Y="5.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2765" Y="0.0714" />
                    <PreSize X="0.7294" Y="1.4143" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_proxy.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="divider_img" ActionTag="1092049472" VisibleForFrame="False" Tag="102" IconVisible="False" LeftMargin="164.0000" RightMargin="-1.0000" TopMargin="-3.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="3" Scale9Height="25" ctype="ImageViewObjectData">
                    <Size X="7.0000" Y="73.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="171.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="1.0059" />
                    <PreSize X="0.0412" Y="1.0429" />
                    <FileData Type="Normal" Path="base/images/main_layer/divider.png" Plist="" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="proxy_btn" ActionTag="-1033118654" Tag="103" IconVisible="False" LeftMargin="-15.0001" RightMargin="61.0001" TopMargin="-37.0000" BottomMargin="2.0000" TouchEnable="True" FontSize="14" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="15" Scale9OriginY="4" Scale9Width="80" Scale9Height="90" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="124.0000" Y="105.0000" />
                    <AnchorPoint ScaleX="0.5000" />
                    <Position X="46.9999" Y="2.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.2765" Y="0.0286" />
                    <PreSize X="0.7294" Y="1.5000" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <NormalFileData Type="Normal" Path="base/images/main_layer/icon_proxy.png" Plist="" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint />
                <Position X="530.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4665" />
                <PreSize X="0.1496" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
              <AbstractNodeData Name="recharge_panel" ActionTag="-1405023310" Tag="104" IconVisible="False" LeftMargin="860.0000" TopMargin="25.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
                <Size X="276.0000" Y="70.0000" />
                <Children>
                  <AbstractNodeData Name="skeleton_node" ActionTag="479626152" Tag="123" IconVisible="True" LeftMargin="130.5000" RightMargin="145.5000" TopMargin="12.0000" BottomMargin="58.0000" ctype="SingleNodeObjectData">
                    <Size X="0.0000" Y="0.0000" />
                    <AnchorPoint />
                    <Position X="130.5000" Y="58.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4728" Y="0.8286" />
                    <PreSize X="0.0000" Y="0.0000" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="recharge_btn" ActionTag="-1647241918" Tag="107" IconVisible="False" LeftMargin="-1.0000" RightMargin="14.0000" TopMargin="-45.0000" BottomMargin="1.0000" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="-15" Scale9OriginY="-4" Scale9Width="30" Scale9Height="8" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                    <Size X="263.0000" Y="114.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="130.5000" Y="58.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.4728" Y="0.8286" />
                    <PreSize X="0.9529" Y="1.6286" />
                    <TextColor A="255" R="65" G="65" B="70" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                  <AbstractNodeData Name="recharge_img" Visible="False" ActionTag="-374566268" VisibleForFrame="False" Tag="535" IconVisible="False" LeftMargin="-0.5000" RightMargin="13.5000" TopMargin="-45.0000" BottomMargin="1.0000" LeftEage="2" RightEage="2" TopEage="24" BottomEage="24" Scale9OriginX="2" Scale9OriginY="24" Scale9Width="219" Scale9Height="61" ctype="ImageViewObjectData">
                    <Size X="263.0000" Y="114.0000" />
                    <AnchorPoint ScaleX="1.0000" />
                    <Position X="262.5000" Y="1.0000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.9511" Y="0.0143" />
                    <PreSize X="0.9529" Y="1.6286" />
                    <FileData Type="Normal" Path="base/images/main_layer/icon_dt_cz.png" Plist="" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="1.0000" />
                <Position X="1136.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="1.0000" />
                <PreSize X="0.2430" Y="0.7368" />
                <SingleColor A="255" R="150" G="200" B="255" />
                <FirstColor A="255" R="150" G="200" B="255" />
                <EndColor A="255" R="255" G="255" B="255" />
                <ColorVector ScaleY="1.0000" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" />
            <Position X="568.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" />
            <PreSize X="1.0000" Y="0.1484" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="item" ActionTag="1265607266" Tag="1459" IconVisible="False" LeftMargin="-22.0000" RightMargin="914.0000" TopMargin="735.0000" BottomMargin="-305.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="244.0000" Y="210.0000" />
            <Children>
              <AbstractNodeData Name="node_nh" ActionTag="2075455239" Tag="120" IconVisible="False" LeftMargin="39.2900" RightMargin="203.7100" TopMargin="49.3600" BottomMargin="159.6400" LeftEage="33" RightEage="33" TopEage="18" BottomEage="18" Scale9OriginX="33" Scale9OriginY="18" Scale9Width="12" Scale9Height="16" ctype="ImageViewObjectData">
                <Size X="1.0000" Y="1.0000" />
                <AnchorPoint ScaleX="1.0000" ScaleY="1.0000" />
                <Position X="40.2900" Y="160.6400" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.1651" Y="0.7650" />
                <PreSize X="0.0041" Y="0.0048" />
                <FileData Type="Normal" Path="base/images/main_layer/update_tip.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="node_qq" ActionTag="-963864730" Tag="121" IconVisible="False" LeftMargin="124.2900" RightMargin="118.7100" TopMargin="112.3600" BottomMargin="96.6400" LeftEage="33" RightEage="33" TopEage="18" BottomEage="18" Scale9OriginX="33" Scale9OriginY="18" Scale9Width="12" Scale9Height="16" ctype="ImageViewObjectData">
                <Size X="1.0000" Y="1.0000" />
                <AnchorPoint ScaleX="1.0000" ScaleY="1.0000" />
                <Position X="125.2900" Y="97.6400" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5135" Y="0.4650" />
                <PreSize X="0.0041" Y="0.0048" />
                <FileData Type="Normal" Path="base/images/main_layer/update_tip.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="update_img" ActionTag="-1657768004" Tag="1460" IconVisible="False" LeftMargin="160.0000" RightMargin="6.0000" TopMargin="6.0000" BottomMargin="152.0000" LeftEage="33" RightEage="33" TopEage="18" BottomEage="18" Scale9OriginX="33" Scale9OriginY="18" Scale9Width="12" Scale9Height="16" ctype="ImageViewObjectData">
                <Size X="78.0000" Y="52.0000" />
                <AnchorPoint ScaleX="1.0000" ScaleY="1.0000" />
                <Position X="238.0000" Y="204.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.9754" Y="0.9714" />
                <PreSize X="0.3197" Y="0.2476" />
                <FileData Type="Normal" Path="base/images/main_layer/update_tip.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="progress_img" ActionTag="-574732921" Tag="1461" IconVisible="False" PositionPercentYEnabled="True" LeftMargin="54.5000" RightMargin="54.5000" TopMargin="37.5000" BottomMargin="37.5000" LeftEage="48" RightEage="48" TopEage="2" BottomEage="2" Scale9OriginX="48" Scale9OriginY="2" Scale9Width="39" Scale9Height="131" ctype="ImageViewObjectData">
                <Size X="135.0000" Y="135.0000" />
                <Children>
                  <AbstractNodeData Name="progress_label" ActionTag="-237534959" Tag="86" IconVisible="False" PositionPercentXEnabled="True" PositionPercentYEnabled="True" LeftMargin="47.5000" RightMargin="47.5000" TopMargin="57.5000" BottomMargin="57.5000" FontSize="20" LabelText="202%" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                    <Size X="40.0000" Y="20.0000" />
                    <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                    <Position X="67.5000" Y="67.5000" />
                    <Scale ScaleX="1.0000" ScaleY="1.0000" />
                    <CColor A="255" R="255" G="255" B="255" />
                    <PrePosition X="0.5000" Y="0.5000" />
                    <PreSize X="0.2963" Y="0.1481" />
                    <OutlineColor A="255" R="255" G="0" B="0" />
                    <ShadowColor A="255" R="110" G="110" B="110" />
                  </AbstractNodeData>
                </Children>
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="122.0000" Y="105.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.5533" Y="0.6429" />
                <FileData Type="Normal" Path="base/images/main_layer/update_cd_bg.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="item_btn" ActionTag="643622172" Tag="1463" IconVisible="False" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="4" BottomEage="4" Scale9OriginX="-15" Scale9OriginY="-4" Scale9Width="30" Scale9Height="8" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="244.0000" Y="210.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="122.0000" Y="105.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="1.0000" Y="1.0000" />
                <TextColor A="255" R="65" G="65" B="70" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="100.0000" Y="-200.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0880" Y="-0.3125" />
            <PreSize X="0.2148" Y="0.3281" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="page_1" ActionTag="757154314" ZOrder="1" Tag="798" IconVisible="False" LeftMargin="500.0000" RightMargin="313.0000" TopMargin="951.0000" BottomMargin="-740.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="323.0000" Y="429.0000" />
            <Children>
              <AbstractNodeData Name="img" ActionTag="478081503" Tag="799" IconVisible="False" LeftMargin="12.0000" RightMargin="12.0000" TopMargin="0.5000" BottomMargin="0.5000" LeftEage="132" RightEage="132" TopEage="63" BottomEage="63" Scale9OriginX="132" Scale9OriginY="63" Scale9Width="35" Scale9Height="303" ctype="ImageViewObjectData">
                <Size X="299.0000" Y="428.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="161.5000" Y="214.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.9257" Y="0.9977" />
                <FileData Type="Normal" Path="base/images/main_layer/official_url_logo1.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="btn" ActionTag="2001732528" Alpha="0" Tag="175" IconVisible="False" LeftMargin="24.3177" RightMargin="23.3177" TopMargin="10.9600" BottomMargin="9.9600" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="16" Scale9Height="14" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="275.3645" Y="408.0800" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="162.0000" Y="214.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5015" Y="0.4988" />
                <PreSize X="0.8525" Y="0.9512" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
                <PressedFileData Type="Default" Path="Default/Button_Press.png" Plist="" />
                <NormalFileData Type="Default" Path="Default/Button_Normal.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="500.0000" Y="-740.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.4401" Y="-1.1563" />
            <PreSize X="0.2843" Y="0.6703" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="page_2" ActionTag="-1640127904" Tag="802" IconVisible="False" LeftMargin="96.0000" RightMargin="717.0000" TopMargin="951.0000" BottomMargin="-740.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="323.0000" Y="429.0000" />
            <Children>
              <AbstractNodeData Name="img" ActionTag="274321441" Tag="803" IconVisible="False" LeftMargin="13.9376" RightMargin="11.0624" TopMargin="2.9072" BottomMargin="-1.9072" LeftEage="80" RightEage="80" TopEage="63" BottomEage="63" Scale9OriginX="80" Scale9OriginY="63" Scale9Width="139" Scale9Height="303" ctype="ImageViewObjectData">
                <Size X="298.0000" Y="428.0000" />
                <AnchorPoint ScaleX="0.4399" ScaleY="0.5619" />
                <Position X="145.0278" Y="238.5860" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.4490" Y="0.5561" />
                <PreSize X="0.9226" Y="0.9977" />
                <FileData Type="Normal" Path="base/images/main_layer/official_url_logo.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="btn" ActionTag="-723805659" Alpha="0" Tag="176" IconVisible="False" LeftMargin="24.3177" RightMargin="23.3177" TopMargin="10.9600" BottomMargin="9.9600" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="16" Scale9Height="14" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="275.3645" Y="408.0800" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="162.0000" Y="214.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5015" Y="0.4988" />
                <PreSize X="0.8525" Y="0.9512" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
                <PressedFileData Type="Default" Path="Default/Button_Press.png" Plist="" />
                <NormalFileData Type="Default" Path="Default/Button_Normal.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="96.0000" Y="-740.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0845" Y="-1.1563" />
            <PreSize X="0.2843" Y="0.6703" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="page_3" ActionTag="-1586497760" ZOrder="1" Tag="171" IconVisible="False" LeftMargin="-312.0000" RightMargin="1125.0000" TopMargin="951.0000" BottomMargin="-740.0000" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="323.0000" Y="429.0000" />
            <Children>
              <AbstractNodeData Name="img" ActionTag="360909158" Tag="172" IconVisible="False" LeftMargin="12.0000" RightMargin="12.0000" LeftEage="132" RightEage="132" TopEage="63" BottomEage="63" Scale9OriginX="132" Scale9OriginY="63" Scale9Width="35" Scale9Height="303" ctype="ImageViewObjectData">
                <Size X="299.0000" Y="429.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="161.5000" Y="214.5000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5000" Y="0.5000" />
                <PreSize X="0.9257" Y="1.0000" />
                <FileData Type="Normal" Path="base/images/main_layer/official_url_logo2.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="btn" ActionTag="1444431760" Alpha="0" Tag="177" IconVisible="False" LeftMargin="24.3177" RightMargin="23.3177" TopMargin="10.9600" BottomMargin="9.9600" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="16" Scale9Height="14" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
                <Size X="275.3645" Y="408.0800" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="162.0000" Y="214.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition X="0.5015" Y="0.4988" />
                <PreSize X="0.8525" Y="0.9512" />
                <TextColor A="255" R="65" G="65" B="70" />
                <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
                <PressedFileData Type="Default" Path="Default/Button_Press.png" Plist="" />
                <NormalFileData Type="Default" Path="Default/Button_Normal.png" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="-312.0000" Y="-740.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="-0.2746" Y="-1.1563" />
            <PreSize X="0.2843" Y="0.6703" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>