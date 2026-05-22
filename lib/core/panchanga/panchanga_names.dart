// lib/core/panchanga/panchanga_names.dart
//
// Devanāgarī + IAST name tables for the five aṅgas of the panchāṅga.
// Pure data — no logic. Indices match the engine in panchanga.dart.

/// A Devanāgarī label paired with its IAST transliteration.
class PanchangaName {
  const PanchangaName(this.deva, this.iast);
  final String deva;
  final String iast;
}

/// The 15 tithi names of one pakṣa. Index 14 differs by pakṣa — see
/// [tithiName] in the engine, which substitutes Amāvāsyā for the Kṛṣṇa 15th.
const List<PanchangaName> tithiNames = [
  PanchangaName('प्रतिपदा', 'Pratipadā'),
  PanchangaName('द्वितीया', 'Dvitīyā'),
  PanchangaName('तृतीया', 'Tṛtīyā'),
  PanchangaName('चतुर्थी', 'Caturthī'),
  PanchangaName('पञ्चमी', 'Pañcamī'),
  PanchangaName('षष्ठी', 'Ṣaṣṭhī'),
  PanchangaName('सप्तमी', 'Saptamī'),
  PanchangaName('अष्टमी', 'Aṣṭamī'),
  PanchangaName('नवमी', 'Navamī'),
  PanchangaName('दशमी', 'Daśamī'),
  PanchangaName('एकादशी', 'Ekādaśī'),
  PanchangaName('द्वादशी', 'Dvādaśī'),
  PanchangaName('त्रयोदशी', 'Trayodaśī'),
  PanchangaName('चतुर्दशी', 'Caturdaśī'),
  PanchangaName('पूर्णिमा', 'Pūrṇimā'),
];

/// Replacement for the 15th tithi of the Kṛṣṇa pakṣa.
const PanchangaName amavasya = PanchangaName('अमावस्या', 'Amāvāsyā');

/// The 27 nakṣatras, in order from Aśvinī (sidereal longitude 0°).
const List<PanchangaName> nakshatraNames = [
  PanchangaName('अश्विनी', 'Aśvinī'),
  PanchangaName('भरणी', 'Bharaṇī'),
  PanchangaName('कृत्तिका', 'Kṛttikā'),
  PanchangaName('रोहिणी', 'Rohiṇī'),
  PanchangaName('मृगशीर्ष', 'Mṛgaśīrṣa'),
  PanchangaName('आर्द्रा', 'Ārdrā'),
  PanchangaName('पुनर्वसु', 'Punarvasu'),
  PanchangaName('पुष्य', 'Puṣya'),
  PanchangaName('आश्लेषा', 'Āśleṣā'),
  PanchangaName('मघा', 'Maghā'),
  PanchangaName('पूर्व फाल्गुनी', 'Pūrva Phalgunī'),
  PanchangaName('उत्तर फाल्गुनी', 'Uttara Phalgunī'),
  PanchangaName('हस्त', 'Hasta'),
  PanchangaName('चित्रा', 'Citrā'),
  PanchangaName('स्वाति', 'Svāti'),
  PanchangaName('विशाखा', 'Viśākhā'),
  PanchangaName('अनुराधा', 'Anurādhā'),
  PanchangaName('ज्येष्ठा', 'Jyeṣṭhā'),
  PanchangaName('मूल', 'Mūla'),
  PanchangaName('पूर्वाषाढा', 'Pūrva Āṣāḍhā'),
  PanchangaName('उत्तराषाढा', 'Uttara Āṣāḍhā'),
  PanchangaName('श्रवण', 'Śravaṇa'),
  PanchangaName('धनिष्ठा', 'Dhaniṣṭhā'),
  PanchangaName('शतभिषा', 'Śatabhiṣā'),
  PanchangaName('पूर्व भाद्रपदा', 'Pūrva Bhādrapadā'),
  PanchangaName('उत्तर भाद्रपदा', 'Uttara Bhādrapadā'),
  PanchangaName('रेवती', 'Revatī'),
];

/// The 27 yogas, in order from Viṣkambha.
const List<PanchangaName> yogaNames = [
  PanchangaName('विष्कम्भ', 'Viṣkambha'),
  PanchangaName('प्रीति', 'Prīti'),
  PanchangaName('आयुष्मान्', 'Āyuṣmān'),
  PanchangaName('सौभाग्य', 'Saubhāgya'),
  PanchangaName('शोभन', 'Śobhana'),
  PanchangaName('अतिगण्ड', 'Atigaṇḍa'),
  PanchangaName('सुकर्मा', 'Sukarmā'),
  PanchangaName('धृति', 'Dhṛti'),
  PanchangaName('शूल', 'Śūla'),
  PanchangaName('गण्ड', 'Gaṇḍa'),
  PanchangaName('वृद्धि', 'Vṛddhi'),
  PanchangaName('ध्रुव', 'Dhruva'),
  PanchangaName('व्याघात', 'Vyāghāta'),
  PanchangaName('हर्षण', 'Harṣaṇa'),
  PanchangaName('वज्र', 'Vajra'),
  PanchangaName('सिद्धि', 'Siddhi'),
  PanchangaName('व्यतीपात', 'Vyatīpāta'),
  PanchangaName('वरीयान्', 'Varīyān'),
  PanchangaName('परिघ', 'Parigha'),
  PanchangaName('शिव', 'Śiva'),
  PanchangaName('सिद्ध', 'Siddha'),
  PanchangaName('साध्य', 'Sādhya'),
  PanchangaName('शुभ', 'Śubha'),
  PanchangaName('शुक्ल', 'Śukla'),
  PanchangaName('ब्रह्म', 'Brahma'),
  PanchangaName('ऐन्द्र', 'Aindra'),
  PanchangaName('वैधृति', 'Vaidhṛti'),
];

/// The 7 movable (cara) karaṇas, repeating through the lunar month.
const List<PanchangaName> movableKaranas = [
  PanchangaName('बव', 'Bava'),
  PanchangaName('बालव', 'Bālava'),
  PanchangaName('कौलव', 'Kaulava'),
  PanchangaName('तैतिल', 'Taitila'),
  PanchangaName('गर', 'Gara'),
  PanchangaName('वणिज', 'Vaṇija'),
  PanchangaName('विष्टि', 'Viṣṭi'),
];

/// The 4 fixed (sthira) karaṇas.
const PanchangaName karanaKimstughna =
    PanchangaName('किंस्तुघ्न', 'Kiṃstughna');
const PanchangaName karanaShakuni = PanchangaName('शकुनि', 'Śakuni');
const PanchangaName karanaChatushpada = PanchangaName('चतुष्पाद', 'Catuṣpāda');
const PanchangaName karanaNaga = PanchangaName('नाग', 'Nāga');

/// The 7 vāras, indexed by `DateTime.weekday` (Mon = 1 … Sun = 7).
const List<PanchangaName> varaNames = [
  PanchangaName('सोमवार', 'Somavāra'), // Mon — weekday 1
  PanchangaName('मङ्गलवार', 'Maṅgalavāra'),
  PanchangaName('बुधवार', 'Budhavāra'),
  PanchangaName('गुरुवार', 'Guruvāra'),
  PanchangaName('शुक्रवार', 'Śukravāra'),
  PanchangaName('शनिवार', 'Śanivāra'),
  PanchangaName('रविवार', 'Ravivāra'), // Sun — weekday 7
];

/// The 12 amānta lunar months, Caitra (index 0) … Phālguna (11).
const List<PanchangaName> lunarMonthNames = [
  PanchangaName('चैत्र', 'Caitra'),
  PanchangaName('वैशाख', 'Vaiśākha'),
  PanchangaName('ज्येष्ठ', 'Jyeṣṭha'),
  PanchangaName('आषाढ', 'Āṣāḍha'),
  PanchangaName('श्रावण', 'Śrāvaṇa'),
  PanchangaName('भाद्रपद', 'Bhādrapada'),
  PanchangaName('आश्विन', 'Āśvina'),
  PanchangaName('कार्तिक', 'Kārttika'),
  PanchangaName('मार्गशीर्ष', 'Mārgaśīrṣa'),
  PanchangaName('पौष', 'Pauṣa'),
  PanchangaName('माघ', 'Māgha'),
  PanchangaName('फाल्गुन', 'Phālguna'),
];
