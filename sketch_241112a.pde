import processing.sound.*; // Import library sound

ArrayList<Cokroach> coks;
PImage img, cakeImg; 
SoundFile backgroundMusic; // Untuk musik latar
SoundFile hitSound; // Untuk efek suara saat membunuh kecoa
int score = 0; 
PVector cakePos; 
boolean gameLost = false; // Menandakan apakah permainan kalah
int lastSpawnTime = 0; // Waktu spawn terakhir
PFont robotoFont;

void setup() {
  size(800, 800);
  coks = new ArrayList<Cokroach>();
  img = loadImage("kecoa.png");
  cakeImg = loadImage("cake.png"); // Gambar kue

  // Set posisi kue tepat di tengah canvas
  cakePos = new PVector(width / 2, height / 2); 
  
  robotoFont = loadFont("Roboto-Black-48.vlw");

  // Load file suara
  loadSounds();

  // Mulai memutar musik latar jika berhasil dimuat
  if (backgroundMusic != null) {
    backgroundMusic.loop(); // Memutar musik latar secara berulang
  }

  // Tambah kecoa secara otomatis
  spawnCokroach();
}

void draw() {
  background(255);
  
  // Gambar kue di tengah dengan posisi presisi
  imageMode(CENTER); // Mengatur mode gambar ke CENTER agar pusat gambar berada di posisi koordinat
  image(cakeImg, cakePos.x, cakePos.y); // Gambar kue tepat di tengah

  // Gambar semua kecoa
  for (Cokroach c : coks) {
    c.live();
    
    // Cek apakah kecoa menyentuh kue
    if (!gameLost && dist(c.pos.x, c.pos.y, cakePos.x, cakePos.y) < cakeImg.width / 2) { 
      gameLost = true;
    }
  }
  
  // Cek apakah pemain kalah
  if (gameLost) {
    fill(255, 0, 0);
    textFont(robotoFont);
    textSize(48);
    text("Kamu Kalah!", width / 2 - 150, height / 2);
    noLoop(); // Hentikan permainan
  } else {
    // Tampilkan skor
    fill(51);
    textFont(robotoFont);
    textSize(16);
    text("Score: " + score, 50, 750); 
  }

  // Tambah kecoa secara otomatis setiap 5 detik
  if (millis() - lastSpawnTime > 5000) {
    spawnCokroach();
    lastSpawnTime = millis(); // Update waktu spawn
  }
}

// Fungsi untuk memuat suara
void loadSounds() {
  try {
    backgroundMusic = new SoundFile(this, "gameBoy.mp3");
    hitSound = new SoundFile(this, "pew.mp3");
  } catch (Exception e) {
    println("Error loading sound files: " + e.getMessage());
  }
}

// Fungsi untuk menambahkan kecoa di posisi acak yang tidak berada di tengah
void spawnCokroach() {
  float x, y;
  do {
    x = random(width);
    y = random(height);
  } while (dist(x, y, cakePos.x, cakePos.y) < cakeImg.width / 2); // Pastikan kecoa tidak berada di area kue
  
  Cokroach newCokroach = new Cokroach(img, x, y);
  coks.add(newCokroach);
}

// Fungsi untuk menangani klik mouse
void mouseClicked() {
  if (mouseButton == LEFT) {
    for (int i = coks.size() - 1; i >= 0; i--) {
      Cokroach c = coks.get(i);
      if (dist(mouseX, mouseY, c.pos.x, c.pos.y) < 25) { 
        coks.remove(i); // Hapus kecoa dari daftar
        if (hitSound != null) {
          hitSound.play(); 
        }
        score++; // Tambah skor

        // Spawn kecoa baru di posisi acak yang tidak berada di tengah
        spawnCokroach(); 
        break;
      }
    }
  }
}

// Kelas Cokroach untuk kecoa
class Cokroach {
  PVector pos;
  PVector vel;
  PImage img;
  float heading;

  Cokroach(PImage _img, float _x, float _y) {
    pos = new PVector(_x, _y);
    vel = PVector.random2D();
    heading = 0;
    img = _img;
  }
  
  void live() {
    pos.add(vel);
    
    if (pos.x <= 0 || pos.x >= width) vel.x *= -1;
    if (pos.y <= 0 || pos.y >= height) vel.y *= -1;
    
    heading = atan2(vel.y, vel.x);
    pushMatrix();
    imageMode(CENTER);
    translate(pos.x, pos.y);
    rotate(heading + 0.5 * PI);
    image(img, 0, 0);
    popMatrix();
  }
}
