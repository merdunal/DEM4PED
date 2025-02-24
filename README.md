# DEM4PED

Bu proje, Hyperledger Besu tabanlı permissioned network ve Foundry ile geliştirme ortamını içeren bir projedir. Aşağıda, projenin Linux ortamında çalıştırılması için gerekli adımlar ve gereksinimler açıklanmıştır.

---

## 1. Ön Hazırlık

### Gereksinimler

#### Java
Hyperledger Besu, OpenJDK (11, 17 veya 21) gerektirir. Örneğin, Ubuntu üzerinde OpenJDK 21 yüklemek için:
```bash
sudo apt update
sudo apt install openjdk-21-jdk
```

Java'nın başarılı şekilde yüklenip yüklenmediğini kontrol etmek için:
```bash
java -version
```

> Olası bir hata durumunda PATH'e eklenip eklenmediğini kontrol edin.

#### Hyperledger Besu
Besu'yu resmi web sitesinden veya paket yöneticiniz aracılığıyla yükleyin. İndirdiğiniz veya derlediğiniz Besu çalıştırılabilir dosyasının PATH üzerinde olduğundan emin olun.
> https://besu.hyperledger.org/private-networks/get-started/install/binary-distribution

#### Git
Projeyi klonlayabilmek için Git'in yüklü olduğundan emin olun. Ubuntu üzerinde Git yüklemek için:
```bash
sudo apt install git
```

#### Foundry
Foundry'yi yüklemek için terminalden aşağıdaki komutları çalıştırın:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
Bu komutlar Foundry'yi kuracak ve forge komutunun sisteminizde kullanılabilir hale gelmesini sağlayacaktır.

## 2. Projeyi GitHub'dan İndirme
Repoyu klonlamak için terminalde aşağıdaki komutu çalıştırın:
```bash
git clone https://github.com/merdunal/DEM4PED.git
cd DEM4PED
```

## 3. Besu Ağını Başlatma
### Adımlar
1. Besu Klasörüne Geçin:
```bash
cd Besu
```
2. Besu Ağını Başlatan Script'i Çalıştırın: Linux'ta Bash varsayılan olarak yüklüdür. Aşağıdaki komutu çalıştırarak ağı başlatın:
```bash
./network.sh start
```
> Bu script, IBFT 2.0 tabanlı permissioned network'ünüzü Node-1'den Node-4'e kadar başlatır ve RPC servislerinin (8545, 8546, 8547, 8548) aktif olduğundan emin olur.
