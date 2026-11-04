// Dear Data 100 — Clothing haul photo session
// Encodes: main_colour (hue), time_taken (x position),
//          flash_used (ring), subject (label on hover)

ArrayList<Photo> photos;
int hovered = -1;

void setup() {
  size(1000, 620);
  photos = new ArrayList<Photo>();
  loadData("data.csv");
  println("Loaded " + photos.size() + " photos (target: 100)");
}

void draw() {
  background(248);
  drawHeader();
  drawTimeline();
  drawPhotos();
  drawHoverInfo();
}

void drawHeader() {
  fill(25);
  textSize(22);
  text("Dear Data 100 — Clothing Haul Photo Session", 30, 36);
  textSize(12);
  fill(90);
  text("Hue = main colour   •   X = time taken   •   Ring = flash used   •   Size = subject length", 30, 58);
  text("Photos: " + photos.size() + " / 100", width - 150, 36);
}

void drawTimeline() {
  // baseline showing the photo session window
  if (photos.isEmpty()) return;
  float minT = photos.get(0).time;
  float maxT = photos.get(0).time;
  for (Photo p : photos) {
    minT = min(minT, p.time);
    maxT = max(maxT, p.time);
  }
  stroke(220);
  strokeWeight(1);
  line(60, height - 70, width - 60, height - 70);
  fill(120);
  textSize(11);
  text("session start", 60, height - 50);
  text("session end", width - 120, height - 50);
}

void drawPhotos() {
  if (photos.isEmpty()) return;

  float minT = photos.get(0).time;
  float maxT = photos.get(0).time;
  for (Photo p : photos) {
    minT = min(minT, p.time);
    maxT = max(maxT, p.time);
  }

  hovered = -1;

  for (int i = 0; i < photos.size(); i++) {
    Photo p = photos.get(i);
    // x = time position across the timeline
    float x = map(p.time, minT, maxT, 80, width - 80);
    // y = stacked in rows so they don't overlap
    float y = 120 + (i % 12) * 36;
    float d = p.diameter();

    boolean over = dist(mouseX, mouseY, x, y) < d / 2 + 4;
    if (over) hovered = i;

    p.display(x, y, d, over);
  }
}

void drawHoverInfo() {
  if (hovered < 0) return;
  Photo p = photos.get(hovered);
  fill(20, 20, 20, 230);
  noStroke();
  rect(20, height - 150, 420, 80, 6);
  fill(255);
  textSize(13);
  text(p.subject, 34, height - 122);
  textSize(11);
  text("colour: " + p.colour + "   flash: " + (p.flash ? "yes" : "no"), 34, height - 102);
  text("time: " + p.timeString, 34, height - 84);
}

void loadData(String filename) {
  String[] lines = loadStrings(filename);
  for (int i = 1; i < lines.length; i++) {
    String line = trim(lines[i]);
    if (line.length() == 0) continue;

    // simple CSV split that respects quoted fields
    String[] parts = splitCsv(line);
    if (parts.length >= 4) {
      String subject = parts[0];
      String colour  = parts[1];
      String timeStr = parts[2];
      boolean flash  = parts[3].equalsIgnoreCase("Yes");
      photos.add(new Photo(subject, colour, timeStr, flash));
    }
  }
}

// handles "quoted, fields" correctly
String[] splitCsv(String line) {
  ArrayList<String> out = new ArrayList<String>();
  boolean inQuotes = false;
  String cur = "";
  for (int i = 0; i < line.length(); i++) {
    char c = line.charAt(i);
    if (c == '"') {
      inQuotes = !inQuotes;
    } else if (c == ',' && !inQuotes) {
      out.add(cur);
      cur = "";
    } else {
      cur += c;
    }
  }
  out.add(cur);
  return out.toArray(new String[0]);
}

// ---------- THE CLASS ----------
class Photo {
  String subject;
  String colour;
  String timeString;
  float time;       // millis since epoch-ish, for x placement
  boolean flash;

  Photo(String subject, String colour, String timeString, boolean flash) {
    this.subject = subject;
    this.colour = colour;
    this.timeString = timeString;
    this.flash = flash;
    this.time = parseTime(timeString);
  }

  // "2023-10-27 10:00:05" -> seconds since midnight of that date
  float parseTime(String s) {
    // split date and time
    String[] bits = split(s, ' ');
    if (bits.length < 2) return 0;
    String[] hms = split(bits[1], ':');
    if (hms.length < 3) return 0;
    return int(hms[0]) * 3600 + int(hms[1]) * 60 + int(hms[2]);
  }

  float diameter() {
    // size scales a little with subject name length (more detail = bigger mark)
    return map(constrain(subject.length(), 3, 30), 3, 30, 14, 30);
  }

  void display(float x, float y, float d, boolean over) {
    color c = colourToColour();
    noStroke();
    fill(c, over ? 255 : 200);
    ellipse(x, y, d, d);

    if (flash) {
      noFill();
      stroke(40, 40, 40, over ? 220 : 120);
      strokeWeight(1.5);
      ellipse(x, y, d + 6, d + 6);
    }
    noStroke();
  }

  color colourToColour() {
    String c = colour.toLowerCase();
    if (c.contains("brown"))  return color(139, 90, 43);
    if (c.contains("black"))  return color(35);
    if (c.contains("grey"))   return color(150);
    if (c.contains("navy"))   return color(30, 50, 120);
    if (c.contains("white"))  return color(235);
    if (c.contains("blue"))   return color(70, 120, 210);
    if (c.contains("red"))    return color(200, 50, 50);
    if (c.contains("yellow")) return color(230, 200, 60);
    if (c.contains("gold"))   return color(200, 160, 40);
    return color(120);
  }
}
