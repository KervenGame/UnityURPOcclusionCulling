# UnityURPOcclusionCulling本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [mp.weixin.qq.com](https://mp.weixin.qq.com/s/XOKiEktMnF3KE4qjs_4SdA)
https://github.com/KervenGame/UnityURPOcclusionCulling

# 效果介绍

当一个角色穿过障碍物的时候，被障碍物遮挡的那部分身体需要使用透明效果来展示。

![null](https://mmbiz.qpic.cn/sz_mmbiz_gif/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgg8fSUwgBVfkzbegBP3UVfic3ud9lBld5fjI5X1v0Bo5wBPN82UHEduw/640?wx_fmt=gif&from=appmsg)

类似的效果在游戏中有非常多的应用，比如 Moba 游戏中玩家进入草丛的效果：

进入草丛前:

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgbmLHibzG9psjib7pZ5SwWZKmictiaiaCuZj6Yk08NjMIu5Uulic2KNTSOerQ/640?wx_fmt=png&from=appmsg)

进入草丛后:
![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgzvnEZibiaicdMkZ9nytMu4wZOyml8hiccUvByUDiaViaL6DzXgocgdEg5HnQ/640?wx_fmt=png&from=appmsg)

当然啦，英雄联盟是进入操作之后整个人都隐身了，我们这里实现的效果是只有进入的部分会隐身，具体的逻辑可以根据游戏玩法的不同而发生改变。  
 

实现方案

接下来分享下在 Unity 中如何实现这种透视效果

## 一、准备工作

我这里使用的是 Unity 2022 版本，尽可能使用新一点的版本吧~

1. 创建一个 Urp 项目：![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgV5DiaFBYgJhRs6hbDRjx4XRkAvdiczVzicMfeFNHAicnWg4wMQTumwZoow/640?wx_fmt=png&from=appmsg)

1. 打开系统自带的场景：**Scenes->SampleScene**

1. 在场景中创建一个：**3DObject->Cube** ，并且设置其 Scale，使其看起来像是一堵墙

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgKcfSice2xwqVSr6OvFVtyHmHgVue7OYj43a4sAmsbc9cjmWVfaOedzQ/640?wx_fmt=png&from=appmsg)

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgicWI6ZmgLp0oqxRAULVSiakYI1QlibiaV9rbdSLJSS0qd0A4hzhCBdU8Bg/640?wx_fmt=png&from=appmsg)

1. 创建一个空物体，并命名为：**Character** ，用来模拟角色。

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgKwWN4XqicmnFRd9exI72AwwujVRcUxyfXVibjTl67GlpWon9S3YYppyg/640?wx_fmt=png&from=appmsg)

- 在 Character 创建三个胶囊（**3DObject->Capsule** ）

- 其中 **Capsule** 是身体

- **Capsule1** 和 **Capsule2** 分别是左手和右手

1. 创建一个 Material，修改颜色为红色，并且拖拽应用到胶囊体身上。



![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgQTlFJxzgicCfskia0hsdnic9jc6l87yicDzib2GkHJXNBuusgmC1fjq3egQ/640?wx_fmt=png&from=appmsg)

1. 这个材质是我们制作的默认效果，胶囊体的最终效果
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgeSiawo233JGOxuCt4AvickIccpLJgJeDzVPk167zO4q9sFXmKxB3Mr0A/640?wx_fmt=png&from=appmsg)
2. 摆放好相机位置，使得三者的位置如下：
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgQ5rB3ypibRM64x3jXSYLqniaOr6ZTh3ljoSx10lA0tjfia9ibzOk88PicUw/640?wx_fmt=png&from=appmsg)
   Scene 视图下：

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgPDEGTbRNICsCbN7COicNcR4vNhibkea3IYCeJlp6t37c7jhrhOhRibUjQ/640?wx_fmt=png&from=appmsg)

## 二、配置 Universal Render Pipeline Asset

要创建通用渲染管线资源，请执行以下操作：

1. 在编辑器中，打开 **Project** 窗口。

1. 在 Project 窗口中单击右键，然后选择 **Create>Rendering>URPAsset** 。或者，导航到顶部的菜单栏，然后单击 **Assets>Create>Rendering>UniversalRenderPipeline>PipelineAsset** 。

1. 命名为：DrawCharacterBehind（这个命名随意看自己的）
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgKaFwwLwlQENmMic7quyenBuvqavGaTXT0TQqaDV0JBMDqxdcGgaXxkw/640?wx_fmt=png&from=appmsg)



要将通用渲染管线资源添加到 **Graphicssettings** 中，请执行以下操作：

1. 导航到 **Edit>ProjectSettings...>Graphics** 。

1. 在 **ScriptableRenderPipelineSettings** 字段中，添加先前创建的通用渲染管线资源。

1. 导航到 **Edit>ProjectSeetings..>Quality** 。

1. 在 **Rendering>RenderPipelineAsset** 字段中。



至此，自定义 Universal Render Pipeline 完成。

三、使用渲染对象渲染器功能 (Render Objects Renderer Feature) 创建自定义渲染效果

1. 点击 **Assets>DrawCharacterBehind_Renderer** ，在 **Inspector** 中点击 **AddRendererFeature** ，创建一个 RenderObjects
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgr4lP6RiaRDLia0eicdQoUNdPTicX1du9XU9A2NMtsDgaImVvpYV522no3Q/640?wx_fmt=png&from=appmsg)

1. 命名为：**DrawCharacterBehind**
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgwibbJ2CKOztd8Puh8PGvkqicLejQp2zrbDs03smyw1zH3iarrPc2TF5nQ/640?wx_fmt=png&from=appmsg)

1. 其中 **LayerMask** 用来界定当前这个 **RendererFeature** 生效的范围，为了限定在胶囊体物体上，我们需要添加一个新的 **Layers** ：**Character**
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgM3MkFianXjkzdHOoJ050D0ibbEO3aZMdW0iaseQ3fFGpSQvBicoumvUu7A/640?wx_fmt=png&from=appmsg)

1. 设置角色的层级为：Character
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgvCyT8duibx8UUcTxKYPibdF6UV69zD98vnYOq7UlD8sE5ORJicCrfc34A/640?wx_fmt=png&from=appmsg)

1. 再回到 **DrawCharacterBehind_Renderer** ，我们发现这时他多了一个子物体：**DrawCharacterBehind**
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgI83DTbNZhOZ8nvt21Kkn7ib8Fdia3ibODUf7ckiceticakbdzeG48sZSH1g/640?wx_fmt=png&from=appmsg)

1. 双击这个子物体，设置 **LayerMask** 为 **Character** ，这样就限定了生效范围仅限 **Character** 层级
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgGCG5bhg50zSmIucutXib0YgjHhlia4gzrfK8PphZKphZl4yicmd5Dyj1A/640?wx_fmt=png&from=appmsg)

1. 另一个比较重要的属性就是 **Overrides** 属性，这个属性表示：当此 **RenderObjects** 生效时，需要采用的替换渲染方式，这里我们选择 **Material** 。就表示，当前 **RenderObjects** 生效时，需要替换为我们自定义的某个材质。
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgHjKicybg3zM1BucHPVFlta8fibtoIRdIN3vfrSK3EAMyhRzaJMeaEibkw/640?wx_fmt=png&from=appmsg)

1. 将深度计算方式修改为：Greater，也就是说距离相机越远的像素会被渲染到距离相机近的像素点的前面。（默认的渲染方式是离得近的才会被渲染，因为可以遮挡后面的物体）

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgsNyO8zVawK8zbyeM1b1iaD9pMMJr6xwhiaicOT0KicTyzrucPUybib5h8yA/640?wx_fmt=png&from=appmsg)

1. 新创建一个 Material，并且将这个材质设置为蓝色（或者其他颜色，总之是用来模拟位于物体背后的效果![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgMY1PasdeS8BmibrJckrzwxlavnwnJs0xPxfALGHjt2icWWpIQ1iaFibxjQ/640?wx_fmt=png&from=appmsg)把这个材质设置为 **Overriders>Material** 中：
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgkJ1xHUChD4JHMa5Hy64XXPxTI1kEBjuWfm5YibMib0V7KLCoaRUbD7mw/640?wx_fmt=png&from=appmsg)  现在我们可以左右拖动角色从墙体背后穿过：![null](https://mmbiz.qpic.cn/sz_mmbiz_gif/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgxFiba6MLWOSnge667nmEBoC7jNZJeFut2ibojgcy7Lys6V98gaicvho0Q/640?wx_fmt=gif&from=appmsg)



## 四、解决自透视问题

在胶囊体中，总共有三部分，身体和两个手臂，当我们靠近认真看时，会发现手臂被身体遮挡的那部分也会显示出透明效果：
![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIg9nAc8suyX2YF37blZgRJCic4ae2rtVjnlbGnQo1zaS2bwljFKYZicibtg/640?wx_fmt=png&from=appmsg)

出现这个现象的核心原因就在于 **DrawCharacterBehind** 的 **Event** 选项使用的是 **AfterRenderingOpaques** 。
这里有一个先后问题，先使用默认挂在角色身上的红色材质进行渲染，而后才轮到 **DrawCharacterBehind** 使用蓝色材质进行渲染。

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgzLyibTEpqn2uNau5pM0OIyWIqul6m143j83MWsPBpClVEibiaIVFmWTTw/640?wx_fmt=png&from=appmsg)

官方的解释是：

- 在执行 URP 渲染器的不透明渲染通道时，Unity 使用 `Character` 材质来渲染属于角色的所有游戏对象，并将深度值写入深度缓冲区。这发生在 Unity 开始执行 `DrawCharacterBehind` 渲染器功能之前，因为默认情况下，新的渲染对象渲染器功能在 **Event** 属性中具有 **AfterRenderingOpaques** 值。**Event** 属性定义了 Unity 从渲染对象渲染器功能注入渲染通道的注入点。URP 渲染器在 **OpaqueLayerMask** 中绘制游戏对象时的事件是 **BeforeRenderingOpaques** 事件。

- 在执行 `DrawCharacterBehind` 渲染器功能时，Unity 使用 **DepthTest** 属性中指定的条件执行深度测试。在下面的屏幕截图中，较大胶囊体遮挡了较小胶囊体的一部分，并且对于较小胶囊体的这个部分，通过了深度测试。渲染器功能会覆盖这个部分的材质。



看上面的流程图，大概就明白了~

**解决方案如下：**

1. 在 **DrawCharacterBehind_Renderer** 中的 **Filtering>OpaqueLayerMask** 中去掉 **Character** 选项，这样默认的不透明渲染就不会对角色进行渲染。这样的效果是，只有在背面时才会显示，因为只有 **RenderObjects** 生效了

![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgjyI16JMqTBHEMibSw5JukdbHw7bCyGedRybOrhIqOZt0h4EulvQkUsQ/640?wx_fmt=png&from=appmsg)

1. 然后在 **DrawCharacterBehind_renderer>AddRendererFeature** 新增一个 **RenderObjects**![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgV3ibQicKuI7TKa6QXfkKAQEmPaMK3pPVV04seK0BmLK5FWibwOOdWsbdg/640?wx_fmt=png&from=appmsg)

1. 设置其生效层级为 **Character** ，设置其 **Overrides** 中的 **Depth** 为 **LeassEqual** (默认深度测试方式)

1. 这样，默认红色材质部分又被渲染出来了。
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgLjWhoW3DGXRaia0RXoSv6JHicDB9cBSyBVyOjh8SdNGDm9MjpqVdnBeA/640?wx_fmt=png&from=appmsg)

1. 在 `DrawCharacterBehind` 渲染器功能的 **Overrides** > **Depth** 中，清除 **WriteDepth** 复选框。根据此设置，`DrawCharacterBehind` 渲染器功能不会更改深度缓冲区，并且 `Character` 渲染器功能在角色位于游戏对象后面时不会绘制角色。
   ![null](https://mmbiz.qpic.cn/sz_mmbiz_png/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgqnic2tIE33dbvb2yT7kErFWp7Pg9UotoedDgIfEQa6Jcodbu89HOx2Q/640?wx_fmt=png&from=appmsg)

1. 最终效果：

![null](https://mmbiz.qpic.cn/sz_mmbiz_gif/gcLI0QeiaZ9epoECfAWvBVpibPADXGULIgUwVJXlNOOQrXh1kiaL44K9TeQicXaqlZVia50t3aeY1E26MzlyibcnpevQ/640?wx_fmt=gif&from=appmsg)

## 五、案例源文件

1. 按理说照着步骤做应该也不需要了，流程已经讲的比较清楚了。

1. 如果中途遇到什么问题，可以加入我的知识星球，做好的工程我会放里面，也可以向我提问，**欢迎交流讨论** ~

1. 开头案例中的透明效果是写了一个简单的 Shader Graph，源码里也会有，后面有机会分享下 Shader 相关的内容。

## 六、参考文献

1. https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@12.1/manual/renderer-features/how-to-custom-effect-render-objects.html

1. https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@12.1/manual/index.html
