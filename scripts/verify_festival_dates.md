# Festival date verification checklist (2027 – 2030)

`lib/data/festivals/festival_dates_future.dart` ships best-effort
Gregorian dates derived from pañcāṅga rules — these MUST be
cross-checked against [Drik Panchang](https://www.drikpanchang.com/)
before we lock v1.0.

## How to verify

1. Open Drik Panchang's year view for the target year — e.g.
   https://www.drikpanchang.com/festivals/festival-list-year.html?year=2027
   (replace `year=` for each).
2. For each festival in the table below, find the corresponding date on
   Drik Panchang. Note: the date listed in our code is the Gregorian
   start date when the tithi begins.
3. If the bundled date matches Drik Panchang → tick ✅.
4. If it differs → write the correct date in the **Drik** column AND
   update `festival_dates_future.dart`.
5. After all 48 entries are verified, drop the "(best-effort)" caveat
   from the file's header comment.

## Sources to cross-reference

- Primary: https://www.drikpanchang.com/festivals/festival-list-year.html?year=YYYY
- Secondary: https://www.mypanchang.com (US-based, calculates for SF Bay
  by default — for North-India dates pick "New Delhi" in their config).
- Tertiary: https://www.vedicrishi.in/festivals (modern, India default).

Two of three matching = lock. If divergence > 1 day → flag to a pandit
or pick Drik Panchang as authoritative.

## Smarta vs Vaishnava — pick Smarta

Janmashtami, Ram Navami, Ekādaśī, etc. have both. We use **Smarta**
(broader observance) consistently — match what Drik Panchang surfaces
as the primary date.

## Regional variant — pick Purnimant (North Indian)

Some festivals fall on different days under Purnimant (North India) vs
Amant (South India / Maharashtra) calendars. We use Purnimant.

---

## Verification rows

### 2027

| Festival | Bundled | Drik (verified) | Status |
|---|---|---|---|
| Makar Sankranti | 2027-01-14 | _ | ☐ |
| Maha Shivratri | 2027-02-17 | _ | ☐ |
| Holi | 2027-03-24 | _ | ☐ |
| Ram Navami | 2027-04-16 | _ | ☐ |
| Hanuman Jayanti | 2027-04-22 | _ | ☐ |
| Guru Purnima | 2027-07-19 | _ | ☐ |
| Janmashtami | 2027-09-04 | _ | ☐ |
| Ganesh Chaturthi | 2027-09-09 | _ | ☐ |
| Navratri | 2027-10-02 | _ | ☐ |
| Dussehra | 2027-10-11 | _ | ☐ |
| Diwali | 2027-11-05 | _ | ☐ |
| Dev Deepawali | 2027-11-14 | _ | ☐ |

### 2028

| Festival | Bundled | Drik (verified) | Status |
|---|---|---|---|
| Makar Sankranti | 2028-01-14 | _ | ☐ |
| Maha Shivratri | 2028-02-06 | _ | ☐ |
| Holi | 2028-03-12 | _ | ☐ |
| Ram Navami | 2028-04-04 | _ | ☐ |
| Hanuman Jayanti | 2028-04-10 | _ | ☐ |
| Guru Purnima | 2028-07-06 | _ | ☐ |
| Janmashtami | 2028-08-23 | _ | ☐ |
| Ganesh Chaturthi | 2028-08-28 | _ | ☐ |
| Navratri | 2028-09-20 | _ | ☐ |
| Dussehra | 2028-09-29 | _ | ☐ |
| Diwali | 2028-10-24 | _ | ☐ |
| Dev Deepawali | 2028-11-02 | _ | ☐ |

### 2029

| Festival | Bundled | Drik (verified) | Status |
|---|---|---|---|
| Makar Sankranti | 2029-01-14 | _ | ☐ |
| Maha Shivratri | 2029-02-25 | _ | ☐ |
| Holi | 2029-03-30 | _ | ☐ |
| Ram Navami | 2029-04-23 | _ | ☐ |
| Hanuman Jayanti | 2029-04-29 | _ | ☐ |
| Guru Purnima | 2029-07-26 | _ | ☐ |
| Janmashtami | 2029-09-11 | _ | ☐ |
| Ganesh Chaturthi | 2029-09-16 | _ | ☐ |
| Navratri | 2029-10-08 | _ | ☐ |
| Dussehra | 2029-10-17 | _ | ☐ |
| Diwali | 2029-11-12 | _ | ☐ |
| Dev Deepawali | 2029-11-21 | _ | ☐ |

### 2030

| Festival | Bundled | Drik (verified) | Status |
|---|---|---|---|
| Makar Sankranti | 2030-01-14 | _ | ☐ |
| Maha Shivratri | 2030-02-14 | _ | ☐ |
| Holi | 2030-03-19 | _ | ☐ |
| Ram Navami | 2030-04-12 | _ | ☐ |
| Hanuman Jayanti | 2030-04-18 | _ | ☐ |
| Guru Purnima | 2030-07-15 | _ | ☐ |
| Janmashtami | 2030-08-31 | _ | ☐ |
| Ganesh Chaturthi | 2030-09-05 | _ | ☐ |
| Navratri | 2030-09-27 | _ | ☐ |
| Dussehra | 2030-10-06 | _ | ☐ |
| Diwali | 2030-10-27 | _ | ☐ |
| Dev Deepawali | 2030-11-10 | _ | ☐ |
