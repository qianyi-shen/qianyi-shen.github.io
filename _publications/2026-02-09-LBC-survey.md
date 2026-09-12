---
title: "Learning-Based Motion Control for Intelligent Vehicles: A Taxonomy from a Closed-Loop Control Perspective"
collection: publications
category: manuscripts
permalink: /publication/survey-lbc
excerpt: 'Learning-based vehicle motion control is organized according to what learning changes: prediction models, control commands, or safety constraints. This perspective explains how different uses of learning affect vehicle behavior and what evidence is needed to assess their performance and safety.'
date: 2026-08-21
authors: [{"name": "Qianyi Shen", "self": true}, {"name": "Lin Zhang", "corresponding": true}, {"name": "Nan Li"}, {"name": "Hong Chen"}, {"name": "Jie Chen"}]
publication_status: submitted
submission_venue: 'IEEE T-ITS'
slidesurl: '/files/lbc-survey-poster.pdf'
slides_label: 'Poster(Chinese)'
---

The same learning algorithm can play different roles in a vehicle controller. A neural network might predict vehicle motion, generate steering commands, or help determine which actions are safe. We organize the literature around these roles through Model Learning, Policy Learning, and Safety Constraint Learning. This makes it possible to compare methods by how their outputs enter the control loop and affect the vehicle, alongside their computational requirements.

We also examine what each role requires from validation. Prediction errors, inappropriate commands, and incorrect safety boundaries affect the vehicle in different ways, so each needs evidence suited to its use. Keeping a conventional controller within a learning-based system preserves useful structure, but its original guarantees do not automatically extend to the combined system. Our review connects these distinctions to evaluation under changing operating conditions, the time needed to produce an executed command, and intervention or fallback behavior.
