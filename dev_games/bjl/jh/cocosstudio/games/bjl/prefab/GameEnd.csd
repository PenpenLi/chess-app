<GameFile>
  <PropertyGroup Name="GameEnd" Type="Node" ID="a12a7d87-00c9-45cd-83d6-91fe89714c7a" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="33" Speed="0.5000">
        <Timeline ActionTag="1114269625" Property="Alpha">
          <IntFrame FrameIndex="0" Value="0">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="9" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="24" Value="255">
            <EasingData Type="0" />
          </IntFrame>
          <IntFrame FrameIndex="33" Value="0">
            <EasingData Type="0" />
          </IntFrame>
        </Timeline>
        <Timeline ActionTag="-2039972566" Property="Position">
          <PointFrame FrameIndex="0" X="-568.0000" Y="50.0000">
            <EasingData Type="0" />
          </PointFrame>
          <PointFrame FrameIndex="6" X="0.0000" Y="50.0000">
            <EasingData Type="0" />
          </PointFrame>
          <PointFrame FrameIndex="24" X="0.0000" Y="50.0000">
            <EasingData Type="0" />
          </PointFrame>
          <PointFrame FrameIndex="33" X="568.0000" Y="50.0000">
            <EasingData Type="0" />
          </PointFrame>
        </Timeline>
        <Timeline ActionTag="-2039972566" Property="VisibleForFrame">
          <BoolFrame FrameIndex="0" Tween="False" Value="True" />
          <BoolFrame FrameIndex="33" Tween="False" Value="False" />
        </Timeline>
      </Animation>
      <ObjectData Name="Node" Tag="1104" ctype="GameNodeObjectData">
        <Size X="0.0000" Y="0.0000" />
        <Children>
          <AbstractNodeData Name="root" ActionTag="1008001367" Tag="1105" IconVisible="True" ctype="SingleNodeObjectData">
            <Size X="0.0000" Y="0.0000" />
            <Children>
              <AbstractNodeData Name="bg_img" ActionTag="1114269625" Alpha="0" Tag="1116" IconVisible="False" LeftMargin="-1000.0000" RightMargin="-1000.0000" TopMargin="-77.5000" BottomMargin="-57.5000" LeftEage="374" RightEage="374" TopEage="44" BottomEage="44" Scale9OriginX="374" Scale9OriginY="44" Scale9Width="388" Scale9Height="47" ctype="ImageViewObjectData">
                <Size X="2000.0000" Y="135.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position Y="10.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="games/hhdz/images/notice_bg.png" Plist="" />
              </AbstractNodeData>
              <AbstractNodeData Name="stop_img" ActionTag="-2039972566" VisibleForFrame="False" Tag="1107" IconVisible="False" LeftMargin="286.5000" RightMargin="-849.5000" TopMargin="-156.5000" BottomMargin="-56.5000" LeftEage="185" RightEage="185" TopEage="68" BottomEage="68" Scale9OriginX="185" Scale9OriginY="68" Scale9Width="193" Scale9Height="77" ctype="ImageViewObjectData">
                <Size X="563.0000" Y="213.0000" />
                <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
                <Position X="568.0000" Y="50.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition />
                <PreSize X="0.0000" Y="0.0000" />
                <FileData Type="Normal" Path="games/hhdz/images/stop.png" Plist="" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="0.0000" Y="0.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>