import type { NextConfig } from "next";
import path from "node:path";

const nextConfig: NextConfig = {
  // このプロジェクトディレクトリをルートとして固定する
  // （上位に別の package-lock.json があるため、ファイルトレースの誤検出を防ぐ）
  outputFileTracingRoot: path.join(__dirname),
};

export default nextConfig;
