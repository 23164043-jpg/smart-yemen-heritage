import * as tf from "@tensorflow/tfjs";

let model = null;

export const loadModel = async (path) => {
  // يمكنك تحميل نموذج محفوظ بصيغة tfjs من مسار URL
  // model = await tf.loadLayersModel(path);
  // return model;
  // حالياً نتركه قابلاً للتوسيع
  console.log("AI model placeholder loaded (no real model yet)");
};

export const simpleTextResponse = async (text) => {
  // دالة وهمية للردوص (يمكنك استبدالها بعد تدريب نموذج فعلي)
  return `رد آلي مبدئي على: "${text.slice(0, 120)}"`;
};
