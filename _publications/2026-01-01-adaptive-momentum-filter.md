---
title: "Adaptive Momentum Zonotopic Filter With Self-Evolving Noise Bounds for Linear Discrete Systems With Time Delay and Its Application"
collection: "publications"
category: "manuscripts"
permalink: "/publication/adaptive-momentum-filter/"
date: "2026-01-01"
date_precision: "year"
authors: [{"name": "Ziyun Wang", "corresponding": true}, {"name": "Jialin Yuan"}, {"name": "Yan Wang"}, {"name": "Qianyi Shen", "self": true}, {"name": "Zhenhua Wang"}]
excerpt: "Adaptive momentum optimization and online adjustment of measurement noise bounds improve state estimation in linear systems with time delay. The method accelerates filter parameter updates and tightens state bounds that would otherwise remain wide because of conservative noise assumptions."
venue: "IEEE Transactions on Instrumentation and Measurement"
paperurl: "https://ieeexplore.ieee.org/abstract/document/11471874"
paper_label: "Publisher"
bibliography: "75: 1–10"
bibtexurl: "/files/adaptive-momentum-filter.bib"
---

Noise bounds are often set conservatively when the actual measurement noise is difficult to characterize. In a zonotopic filter, these loose bounds can lead to unnecessarily wide state estimates. We address this problem for linear systems with time delay by combining adaptive momentum optimization with a mechanism that updates measurement noise bounds during estimation. Momentum helps the filter optimize its parameters, while the noise update uses current and historical information to reduce excess uncertainty.

We evaluate the method on an experimental buck-boost circuit, estimating inductor current and capacitor voltage. Compared with the filters considered in the paper, it produces tighter state bounds. Comparing versions with and without noise adaptation also shows how updating the noise bounds reduces conservatism beyond what momentum optimization achieves alone.
