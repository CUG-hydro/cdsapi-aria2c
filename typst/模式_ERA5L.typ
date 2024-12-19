// #import "../typst/lib.typ": *
#import "@preview/modern-cug-report:0.1.0": *

#show: (doc) => template(doc, 
  size: 11.5pt,
  footer: "CUG水文气象学2024",
  header: "ERA5L模型结构")
#counter(heading).update(0)
#set par(leading: 1.24em)
#codly(number-format: none)
#show figure.caption: set par(leading: 0.7em)

#let pkg-table-figure(it) = {
  show table.cell.where(y: 0): strong
  // See the strokes section for details on this!
  let frame(stroke) = (x, y) => (
    left: 0pt, right: 0pt,
    // left: if x > 0 { 0pt } else { stroke },
    // right: stroke,
    // top: if y < 2 { stroke } else { 0pt },
    // bottom: stroke,
    top: 0pt,
    bottom: 0pt,
  )
  set table(
    // fill: (rgb("EAF2F5"), none),
    stroke: frame(rgb("21222C")),
    align: (x, y) => ( if x > 0 { center } else { left } )
  )
  it
}

#let table-figure(caption, img, width: 80%) = {
  pkg-table-figure[#figure(
    caption: [#caption #v(-0.8em)],
    table(image(img, width: width))
  )] 
  v(-1em)
}


= ERA5-Land陆面模式HTESSEL

== Tiles划分

根据GLCC（Global Land Cover Characteristics，）数据，将每个网格的植被划分为高植被与矮植被。每个网格有四个变量，
T_H: 占优的高植被类型、T_L: 占优的矮植被类型、A_H: 高植被覆盖比例、A_L: 矮植被覆盖比例。
GLCC数据说明见https://www.usgs.gov/centers/eros/science/usgs-eros-archive-land-cover-products-global-land-cover-characterization-glcc，下载地址见https://earthexplorer.usgs.gov/。

#figure(
  image("../images/ERA5/ERA5L_land_surface-HTESSEL.png", width: 40%),
  caption: [ERA5-Land陆面模式HTESSEL结构示意图]
) <fig_LSM_HTESSEL>

如下表，ERA5L中将每个网格进一步划分为有8种Tiles。
// #line(length: 100%, stroke: 1pt + rgb("CCCCCC"))

#figure(
  caption: [ERA5L中8种Tiles],
  table(
    columns: (1.5cm, 4cm, 4cm, 5.7cm),
    // inset: 10pt,
    align: (horizon, horizon, horizon, left),
    table.header( [编号], [类型], [积雪], [比例]),
    [1], [水体中的水     ], [水体     ], [$1 - c_i$],
    [2], [水体中的冰$c_i$], [水体     ], [$c_i$], 
    [3], [冠层水体       ], [无积雪部分], [$(1 - c_"sn") c_1$], 
    [4], [矮植被        ], [无积雪部分], [$(1 - c_"sn")(1 - c_1) c_L$], 
    [5], [矮植被和裸土   ], [积雪覆盖 ], [#h(2em) $c_"sn" (1 - c_H)$], 
    [6], [高植被        ], [无积雪部分], [$(1 - c_"sn")(1 - c_1) c_H$], 
    [7], [高植被        ], [积雪覆盖  ], [#h(2em) $c_"sn" c_H$], 
    [8], [裸土          ], [无积雪部分], [$(1 - c_"sn")(1 - c_1) (1 - c_H - c_L)$], 
  )
)
其中，$c_1$：冠层截留的比例；$c_"sn"$：雪的比例；$c_i$：冰的比例。
高植被、矮植被、裸地的覆盖比例为：$c_H = A_H c_"veg"(T_H)$、
$c_L = A_L c_"veg"(T_L)$、$c_B = 1 - c_H - c_L$。




== 感热与潜热通量

#figure(
  image("../images/ERA5/阻力示意图.png", width: 70%),
  caption: [对热量和水汽的传递阻力示意图。从左到右分别为，裸土、植被、积雪与植被。]
) <fig_>

$ E_i = rho_a / (r_a + r_c) [q_L - q_"sat"(T_i)] $

- 下标L代表lowest atmospheric model level，可理解为参考高度；
- 下标i代表the high or low vegetation tiles。

== 冠层蒸腾阻力

ERA5L采用的是Jarvis (1976)气孔导度公式：

$ r_c = r_"s,min" / "LAI" f_1(R_s) f_2 (overline(theta)) f_3 (D_a) $

$ 1 / f_1(R_s) = min[1, (b R_s + c) / (a (b R_s + 1))] $ 

$ 1 / f_2(overline(theta)) = cases(
  0 "," overline(theta) < theta_"pwp",
  (overline(theta) - theta_"pwp") / (theta_"cap" - theta_"pwp") "," theta_"pwp" <= overline(theta) <= theta_"cap",
  1 "," overline(theta) > theta_"cap",
)  $

$ 1 / f_3(D_a) = exp ( - g_D D_a ) $

其中，a = 0.81，b = 0.004 $W^(-1) m^2$， c = 0.05。$R_s$为入射短波辐射，$D_a$为空气饱和水气压差，$overline(theta)$是根系比例加权之后的，有效土壤含水量。

$ overline(theta) = sum_(k=1)^4 R_k max[f_"liq,k" theta_k, theta_"pwp"] $

其中$R_k$为根系分布比例，采用的Zeng et al. (1998)经验公式：

$ R(z) = 0.5 [ exp (- a_r z) + exp (- b_r z) ] $
$ R_k = R(z_(k - 1/2)) - R(z_(k + 1/2)) $


#table-figure(
  [ERA5L植被参数。],
  "../images/ERA5/Table_veg_param.png", width: 80%
) <tab_veg_param>

其中，$c_"veg"$为覆盖度，$r_"s,min"$为最低冠层阻力，$g_D$为冠层导度参数，$a_r$、$b_r$为植被根系分布参数。


#table-figure(
  [每层土壤的植被根系分布比例。Vegetation Index对应的植被类型见表#[@tab_veg_param]。],
  "../images/ERA5/Table_root_ratio.png", width: 100%)

== 土壤蒸发阻力

$ r_"soil" = r_"soil,min" f_"2b"(f_"liq" theta_1) $

$ 1 / f_"2b"(f_"liq" theta_1) = 
  (theta_1 - theta_"min") / (theta_"cap" - theta_"min") $

$ theta_"min" = "veg" theta_"pwp" + (1 - "veg") theta_"res" $

== 土壤水运动

早期的TESSEL采用的是Campbell（1974）土水势函数，而最新的版本采用的是Van Genuchten（1980）。

#beamer-block[土壤质地数据来源于：FAO (FAO, 2003)。]

#table-figure(
  [Values for the volumetric soil moisture in Van Genuchten and Clapp-Hornberger (CH, loamy; bottom row).],
  "../images/ERA5/Table_soil_pot_param.png", width: 80%)

#table-figure(
  [Values for the volumetric soil moisture in Van Genuchten and Clapp-Hornberger (CH, loamy; bottom row).],
  "../images/ERA5/Table_soil_pot_param.png", width: 80%)

#figure(
  image("../images/ERA5/Figure_soil_hydra.png", width: 90%),
  caption: [土壤水力属性。每条线有三个"+"，它们分别代表$theta_"sat"$、$theta_"fc"$、$theta_"pwp"$。]
) <fig_>

上图可以看到，在土壤含水量低于$theta_"pwp"$之后，$"CH"$的扩散系数和水力传导系数是被高估的。
