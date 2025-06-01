# XSC002
# ZXHELL X ZEDLIST - Skrip Otomatisasi Roblox

Skrip otomatisasi client-side untuk Roblox yang dirancang untuk menjalankan serangkaian tugas berdasarkan alur yang telah ditentukan, dilengkapi dengan antarmuka pengguna (UI) untuk kontrol dan konfigurasi timer.

## Deskripsi

Skrip ini mengotomatiskan berbagai aksi dalam game Roblox, seperti reinkarnasi, pembelian item, perubahan peta, dan tugas-tugas spesifik lainnya sesuai dengan "Alur script roblox". Dilengkapi dengan UI yang interaktif, pengguna dapat memulai, menghentikan, dan meminimalkan panel kontrol, serta menyesuaikan durasi timer penting langsung dari dalam game. Skrip ini juga menampilkan judul "ZXHELL X ZEDLIST" dengan animasi warna RGB yang menarik.

## Fitur Utama

* **Otomatisasi Alur Komprehensif**: Mengikuti logika dari "Alur script roblox" untuk menjalankan tugas-tugas secara berurutan.
    * Reinkarnasi otomatis.
    * Pembelian set item yang telah ditentukan.
    * Perubahan peta otomatis (`immortal`, `chaos`).
    * Aktivasi `ChaoticRoad`, `HiddenRemote`, `ForbiddenZone`.
    * Manajemen fase `Comprehend` dan `UpdateQi` (termasuk jeda otomatis).
* **Antarmuka Pengguna (UI) Interaktif**:
    * Tombol **Start/Stop Script** untuk memulai dan menghentikan eksekusi skrip.
    * **Status Label** untuk menampilkan aksi yang sedang berjalan atau pesan error.
    * **Nama UI "ZXHELL X ZEDLIST"** dengan animasi warna teks RGB merah yang halus dan efek *glitch* ringan.
    * **Tombol Minimize (-/+)** untuk menyembunyikan/menampilkan bagian detail UI, menjaga layar tetap rapi.
    * Frame UI yang dapat digeser (*draggable*).
* **Konfigurasi Timer via UI**:
    * Input teks untuk menyesuaikan durasi timer utama dari "Alur script roblox":
        * `Wait Pasca Item1` (Setelah pembelian item set pertama, sebelum ganti map)
        * `Wait Item2 (QI Hidden)` (Durasi tunggu dengan UpdateQi dijeda, sebelum pembelian item set kedua)
        * `Durasi Comprehend`
        * `Durasi Post-Comp QI` (UpdateQi setelah Comprehend)
    * Tombol "Terapkan Semua Timer" untuk menyimpan perubahan konfigurasi.
* **Loop Latar Belakang**:
    * Loop `IncreaseAptitude` dan `Mine` berjalan secara independen.
    * Loop `UpdateQi` berjalan setiap detik dan dikelola secara otomatis (dijeda saat `Comprehend` atau saat kondisi "UpdateQi di hidden").
* **Penanganan Kesalahan**: Pemanggilan `RemoteEvent` dibungkus `pcall` untuk mencegah skrip berhenti total jika terjadi error, dengan pesan ditampilkan di Status Label.
* **Pengaturan Timer Internal**: Selain UI, semua durasi tunggu dapat dikonfigurasi melalui tabel `timers` di dalam kode skrip untuk penyesuaian yang lebih detail.
* **Client-Side**: Skrip dan UI berjalan sepenuhnya di sisi klien dan hanya terlihat oleh pengguna yang menjalankan skrip.

## Cara Penggunaan

1.  **Persyaratan**:
    * Game Roblox.
    * Eksekutor skrip client-side yang mendukung `loadstring` atau metode eksekusi skrip serupa.
2.  **Instalasi**:
    * Salin seluruh kode skrip dari file `main.lua` (atau nama file yang Anda gunakan).
    * Tempelkan ke dalam eksekutor skrip Anda.
3.  **Menjalankan Skrip**:
    * Eksekusi skrip melalui eksekutor Anda saat berada di dalam game.
    * Panel UI "ZXHELL X ZEDLIST" akan muncul di layar.
4.  **Interaksi dengan UI**:
    * **Start/Stop**: Klik tombol "Start Script" untuk memulai otomatisasi. Tombol akan berubah menjadi "Running...". Klik lagi untuk menghentikan skrip.
    * **Konfigurasi Timer**:
        * Masukkan durasi yang diinginkan (dalam detik) ke dalam kotak input teks yang tersedia di bawah "Konfigurasi Timer Alur".
        * Klik tombol "Terapkan Semua Timer" untuk menyimpan perubahan. Timer akan diterapkan pada siklus berikutnya atau saat relevan.
    * **Minimize/Maximize**: Klik tombol "-" di pojok kanan atas panel untuk mengecilkan panel (hanya menampilkan judul, tombol Start/Stop, dan status). Klik tombol "+" untuk mengembalikan panel ke ukuran penuh.
    * **Geser Panel**: Klik dan tahan pada bagian atas panel (area kosong atau judul) untuk menggeser posisinya di layar.

## Konfigurasi Lanjutan (dalam Skrip)

Selain melalui UI, Anda dapat menyesuaikan *semua* timer default dan beberapa penundaan operasi kecil dengan mengedit tabel `timers` di bagian awal skrip. Contoh:

```lua
local timers = {
    wait_1m30s_after_first_items = 90, 
    alur_wait_40s_hide_qi = 40,             
    -- ... timer lainnya ...
    buyItemDelay = 0.25, 
    changeMapDelay = 0.5,
}
