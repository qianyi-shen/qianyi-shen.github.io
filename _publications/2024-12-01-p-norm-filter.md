---
title: "基于 P 范数的线性时滞系统多胞空间滤波器设计"
collection: "publications"
category: "manuscripts"
permalink: "/publication/p-norm-filter/"
date: "2024-12-01"
date_precision: "year"
authors: [{"name": "沈谦逸", "self": true}, {"name": "王子赟", "corresponding": true}, {"name": "王艳"}]
excerpt: "针对噪声分布未知但边界已知的线性时滞系统, 利用 P 范数优化多胞体滤波器, 缩小状态估计范围. 风力发电机变桨执行器仿真表明, 该方法在包裹真实状态的同时, 能够给出更紧的估计边界."
venue: "控制与决策"
paperurl: "https://kns.cnki.net/kcms2/article/abstract?v=a4fp6zKrpgYfL6nt9Jey4H3SLv4s5J3d1wL_BaF7L608QRcagvON-rRtLZrMVN7STbp5BXWBOo7pLGMh2PESE0r41jFOGafmuXSSfMPOjNswGbuJvz6c3td8G9xT5W2L-cF37E3bsWE2KsnZkCdjWoDQBp42R2QZ4ldZXiTgpKWNjk5zSB6fcA==&uniplatform=NZKPT&language=CHS"
paper_label: "Publisher"
bibliography: "39(12): 4209–4216"
title_lang: "zh-CN"
lang: "zh-CN"
bibtexurl: "/files/p-norm-filter.bib"
---

对于存在时滞的系统, 当前状态还会受到过去状态的影响; 当噪声的概率分布难以确定时, 状态估计也需要考虑这部分不确定性. 在这项工作中, 我们根据已知的噪声边界, 用多胞体描述状态的可能范围, 并研究如何让这个范围在滤波过程中更紧密地包裹真实状态.

我们引入 P 范数衡量多胞体的大小, 将时滞的影响纳入滤波器设计, 通过求解线性矩阵不等式优化滤波参数. 在风力发电机液压变桨执行器的仿真中, 该方法能够跟踪桨距角及其变化率, 并获得比文中对比方法更紧的状态边界, 减少估计范围中的冗余.
