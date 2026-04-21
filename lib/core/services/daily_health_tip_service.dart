import 'package:shared_preferences/shared_preferences.dart';

class DailyHealthTipData {
  final String tip;
  final String? awareness;
  final String thought;

  const DailyHealthTipData({
    required this.tip,
    this.awareness,
    required this.thought,
  });
}

class DailyHealthTipService {
  DailyHealthTipService._();

  static const _keyDate = 'dht_date';
  static const _keyTip = 'dht_tip';
  static const _keyAwareness = 'dht_awareness';
  static const _keyThought = 'dht_thought';

  /// Returns a cached tip for today, or generates + caches a fresh one.
  static Future<DailyHealthTipData> getDailyTip() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    // Return cached result if it's from today
    if (prefs.getString(_keyDate) == todayKey) {
      return DailyHealthTipData(
        tip: prefs.getString(_keyTip) ?? _tips.first,
        awareness: prefs.getString(_keyAwareness),
        thought: prefs.getString(_keyThought) ?? _thoughts.first,
      );
    }

    // Generate a new tip for today
    final data = _buildForDate(now);

    // Persist so subsequent calls are instant
    await prefs.setString(_keyDate, todayKey);
    await prefs.setString(_keyTip, data.tip);
    if (data.awareness != null) {
      await prefs.setString(_keyAwareness, data.awareness!);
    } else {
      await prefs.remove(_keyAwareness);
    }
    await prefs.setString(_keyThought, data.thought);

    return data;
  }

  static DailyHealthTipData _buildForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final tip = _tips[dayOfYear % _tips.length];
    final thought = _thoughts[dayOfYear % _thoughts.length];
    final awarenessKey = '${date.month}_${date.day}';
    final awareness = _awarenessCalendar[awarenessKey];
    return DailyHealthTipData(tip: tip, awareness: awareness, thought: thought);
  }

  // ── Medical / Health Awareness Days (month_day) ─────────────────────────
  static const Map<String, String> _awarenessCalendar = {
    '1_22': '🎗️ Cervical Cancer Awareness Day — Get your Pap smear done; early detection saves lives.',
    '2_4':  '🎗️ World Cancer Day — Know your body, attend screenings, and advocate for your health.',
    '3_8':  '💜 International Women\'s Day — Celebrate your strength and invest in your well-being today.',
    '4_7':  '🌍 World Health Day — Small daily health habits compound into a lifetime of vitality.',
    '5_12': '🏥 International Nurses Day — Thank a nurse and remember to be kind to yourself too.',
    '5_28': '🌸 Menstrual Hygiene Day — Break the stigma; a healthy period is nothing to be ashamed of.',
    '9_26': '💊 World Contraception Day — Informed choices about reproductive health are your right.',
    '10_1': '🎀 Breast Cancer Awareness Month begins — Schedule your self-exam and annual mammogram.',
    '10_10':'🧠 World Mental Health Day — Prioritise your mental health as much as your physical health.',
    '10_15':'🤲 Global Handwashing Day — Simple hygiene is one of the most powerful health tools.',
    '11_14':'🩺 World Diabetes Day — Women face unique diabetes risks; watch your sugar and move daily.',
    '11_25':'🟣 Day against Violence against Women — You deserve safety, respect, and dignity always.',
  };

  // ── Daily Health Tips (women-focused, 30 entries) ────────────────────────
  static const List<String> _tips = [
    // Menstrual health
    'During your period, warm ginger or chamomile tea can ease cramping by relaxing uterine muscles. Stay hydrated and skip ice-cold drinks to reduce bloating.',
    'Tracking your cycle helps you spot irregularities early. Note pain levels, flow, and mood each day — your period is a monthly health report card.',
    'Iron levels drop during menstruation. Eat iron-rich foods like spinach, lentils, and dates in your period week, and pair them with vitamin C for better absorption.',
    'Gentle yoga poses — child\'s pose, supine twist, and forward fold — increase pelvic circulation and naturally reduce period cramps within minutes.',
    'PMS cravings for sugar and salt are driven by hormonal fluctuations. Satisfy cravings with dark chocolate or nuts rather than processed snacks.',
    'A regular sleep schedule helps regulate hormones that control your cycle. Aim for 7–9 hours even during your period to reduce symptom severity.',
    'Magnesium deficiency amplifies PMS symptoms. Include pumpkin seeds, dark leafy greens, and almonds regularly throughout your cycle.',

    // Pregnancy & fertility
    'Folic acid (400 mcg daily) is crucial in the first 12 weeks of pregnancy and ideally before conception, when the baby\'s neural tube forms.',
    'During pregnancy, sleep on your left side to improve blood flow to the placenta and reduce pressure on your kidneys and back.',
    'Staying active during pregnancy with walking or prenatal yoga reduces back pain, improves sleep, and prepares your body for labour.',
    'Hydration is critical during pregnancy — aim for 2.5–3 litres of water daily to support amniotic fluid, nutrient transport, and digestion.',

    // Mental wellness
    'Hormonal changes throughout your cycle directly affect serotonin levels. If you feel low mid-luteal phase, add gentle movement and sunlight to your routine.',
    'Journalling for just 5 minutes each morning can reduce cortisol, improve self-awareness, and help you identify patterns in your emotional health.',
    'Boundaries are not walls — they are acts of self-care. Saying no to what drains you protects your energy for what truly matters.',
    'Anxiety often peaks just before your period due to progesterone shifts. Deep breathing (4-7-8 technique) can calm your nervous system within 2 minutes.',
    'Social connections protect mental health more than we realise. One meaningful conversation per day can significantly reduce feelings of isolation.',

    // Nutrition for women
    'Calcium and vitamin D work together for strong bones. Women lose bone density after 35 — include dairy, fortified foods, and safe sun exposure daily.',
    'Phytoestrogens in flaxseeds, soy, and chickpeas may help balance oestrogen levels naturally, especially useful during perimenopause.',
    'Omega-3 fatty acids (found in walnuts, chia seeds, and fatty fish) reduce inflammation associated with period pain, PCOS, and endometriosis.',
    'A rainbow diet — eating vegetables of 5+ different colours daily — ensures you get a wide spectrum of antioxidants vital for hormonal and cellular health.',
    'Processed seed oils and trans fats increase inflammation and disrupt hormones. Cook with ghee, cold-pressed coconut, or olive oil instead.',

    // Hormonal balance
    'Chronic stress elevates cortisol, which directly suppresses progesterone production and can cause irregular cycles. Stress management is hormone management.',
    'Blood sugar spikes and crashes drive hormonal chaos. Eat protein, fat, and fibre at every meal to keep glucose stable throughout the day.',
    'Plastics containing BPA and phthalates can mimic oestrogen in the body. Switch to glass or stainless steel containers for food and water storage.',
    'Regular exercise — even 30 minutes of brisk walking — improves insulin sensitivity and helps regulate testosterone and oestrogen levels.',

    // Fitness for women
    'Strength training twice a week protects bone density, boosts metabolism, and improves insulin sensitivity — all especially important for women after 30.',
    'The follicular phase (days 1–14 of your cycle) is your peak energy window. Schedule your most intense workouts during this phase for best results.',
    'During the luteal phase (days 15–28), your body runs hotter and recovers slower. Swap intense HIIT for Pilates, swimming, or yoga.',
    'Pelvic floor exercises (Kegels) done daily prevent incontinence, improve sexual health, and support posture — take 2 minutes morning and night.',
    'Post-workout protein within 30–45 minutes supports muscle repair. For women, 20–30 g of protein (eggs, paneer, yoghurt) is ideal after exercise.',
  ];

  // ── Motivational Thoughts (15 entries) ───────────────────────────────────
  static const List<String> _thoughts = [
    'Take care of your body — it\'s the only place you have to live.',
    'Healing is not linear, but every small step forward counts.',
    'You are stronger than any challenge your body faces.',
    'Rest is not weakness. Rest is part of the work.',
    'Your health is an investment, not an expense.',
    'Be patient with yourself — real change grows slowly and roots deeply.',
    'A healthy woman lifts every person around her.',
    'Listen to your body — it whispers before it screams.',
    'You don\'t have to be perfect to be worthy of care.',
    'Progress, not perfection, is the goal every single day.',
    'Small consistent actions build extraordinary health over time.',
    'Your wellbeing matters as much as anyone else\'s.',
    'Nourish yourself like you matter — because you do.',
    'Every cycle, every season of your body deserves respect.',
    'Choose yourself first so you can show up fully for others.',
  ];
}
