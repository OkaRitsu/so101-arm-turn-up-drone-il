# so101-arm-turn-up-drone-il

## 動作環境

### 物品一覧

| 品名 | 概要 | URL |
| --- | --- | --- |
|SO-101 オープンソースロボットアームキット ACアダプター付 | SO-101 のキット | https://akizukidenshi.com/catalog/g/g131169/ |
| SO-101 オープンソースロボットアームキット 3Dプリントパーツ | SO-101 別売り3Dプリントパーツ | https://akizukidenshi.com/catalog/g/g131222/ |
| InnoMaker 1080P USB2.0 UVCカメラ | リストカメラ | https://amzn.asia/d/044Y8uVI |
| EMEET Webカメラ HD1080P | トップダウンカメラ | https://amzn.asia/d/0gSu38r2 |
| UGREEN タブレット アーム スタンド | トップダウンカメラ固定用アーム | https://amzn.asia/d/050aB4Ze |
| DJI Tello | ドローン | https://amzn.asia/d/0i7mjUqO |

別途 USBハブが必要。USB type-C → USB A $\times$ 4（SO101 リーダ・フォロワ、リストカメラ、トップダウンカメラ）。

### テレオペ・推論環境

- MacBook Air
- Apple M1
- 16 GB メモリ

### 学習環境

- [RunPod](https://www.runpod.io/)
- Pod: https://console.runpod.io/hub/group/cmqv25r6f007xhm5vv53kv5t4?selectedTemplate=runpod-torch-v280
- GPU: RTX 4090

## セットアップ

```
git clone https://github.com/OkaRitsu/so101-arm-turn-up-drone-il.git  --recursive
cd so101-arm-turn-up-drone-il
uv sync # テレオペ・推論環境
pip install -e .[training]  # 学習環境
```

### 環境変数
`scripts/`以下のコマンドは、実行環境によって変わるシリアルポート、カメラのインデックス、Hugging Faceのユーザー名をルートディレクトリの`.env`から読み込みます。

```bash
cp .env.example .env
```

#### SO-101 ポート

[SO-101公式手順](https://huggingface.co/docs/lerobot/so101#configure-the-motors)に従い、リーダーまたはフォロワーのMotorBusを1台だけUSB接続し、LeRobotディレクトリでポート検出を実行します。

```bash
uv run lerobot-find-port
```

画面の指示に従ってUSBケーブルを抜き差しすると、そのMotorBusのポートが表示されます。どちらのアームか分かるように、リーダーとフォロワーを1台ずつ接続して確認してください。確認が終わったら、表示されたポートを使って登録します。

```bash
echo 'LEADER_PORT=/dev/tty.usbmodemXXXXXXXX' >> .env
echo 'FOLLOWER_PORT=/dev/tty.usbmodemYYYYYYYY' >> .env
```

`/dev/tty...`の部分は検出結果に置き換えてください。Linuxでは`/dev/ttyACM...`などが表示される場合があります。

#### Hugging Faceユーザー

まず書き込み可能なトークンでログインします。

```bash
uv run --no-sync hf auth login
```

ログイン後、次のコマンドをリポジトリのルートで実行すると、ログイン中のユーザー名を`.env`に追記できます。

```bash
echo "HF_USERNAME=$(uv run  --no-sync python -c 'from huggingface_hub import HfApi; print(HfApi().whoami()["name"])')" >> .env
```

#### カメラのインデックス

カメラのインデックスは、接続環境に合わせて`.env`の`WRIST_CAMERA_INDEX`と`TOP_CAMERA_INDEX`に設定してください。例えば、リスト内の先頭のカメラがtop、2番目がwrist cameraなら次のように登録します。

```bash
echo 'WRIST_CAMERA_INDEX=1' >> .env
echo 'TOP_CAMERA_INDEX=0' >> .env
```

## スクリプト

以下のコマンドはすべてリポジトリのルートで実行します。ロボットを使う操作の前に、アームの接続とキャリブレーションを済ませてください。

| 内容 | コマンド |
| --- | --- |
| リーダーのキャリブレーション | `./scripts/calibrate-leader.sh` |
| フォロワーのキャリブレーション | `./scripts/calibrate-follower.sh` |
| テレオペ | `./scripts/teleoperate.sh` |
| データ収集 | `./scripts/record-dataset.sh` |
| SmolVLA学習 | `./scripts/train-smolvla.sh` |
| SmolVLAロールアウト | `./scripts/rollout-smolvla.sh` |

収集エピソード数、削除対象、学習パラメーターなどの既定値は各スクリプト内で設定しています。`record-dataset.sh` と `rollout-smolvla.sh` は末尾に LeRobot のオプションを追加して上書きできます。`train-smolvla.sh` は最初の引数が実験名、それ以降が上書きオプションです。

## データ収集

```bash
./scripts/calibrate-leader.sh
./scripts/calibrate-follower.sh
./scripts/teleoperate.sh
./scripts/record-dataset.sh
```

初回の収集は `--resume=false` です。既存の収集に追加する場合だけ `./scripts/record-dataset.sh --resume=true` とします。現在のスクリプトはローカルデータを `lerobot/data/so101-turn-up-drone` に保存します。リポジトリ直下の `data/` とは異なります。

```bash
./scripts/edit-dataset.sh
```

https://huggingface.co/spaces/lerobot/visualize_dataset で　`YOUR_HF_USERNAME/so101-turn-up-drone` でエピソードを可視化し、 Hub 上にデータセットがあることを確認してください。

## 学習

学習には、Nvidia の GPU を使用します。

```
./scripts/train-smolvla.sh
```

## 推論

学習したモデルを使って実機でロールアウトします。

```bash
wandb login
./scripts/rollout-smolvla.sh
```

## 関連リンク

| URL | 概要 |
| --- | --- |
| [Imitation Learning on Real-World Robots](https://huggingface.co/docs/lerobot/il_robots) | データ収集・学習・評価の手順 |
| [SO-101](https://huggingface.co/docs/lerobot/so101) | ポート検出・セットアップ・キャリブレーション |
| [Hugging Face \| so101-turn-up-drone](https://huggingface.co/datasets/OkzRIKU/so101-turn-up-drone) | データセットのリポジトリ |
| [Hugging Face \| smolvla-turn-up-drone](https://huggingface.co/OkzRIKU/smolvla-turn-up-drone) | 学習済みモデルのリポジトリ |