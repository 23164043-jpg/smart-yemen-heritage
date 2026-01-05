export default (io) => {
  io.on("connection", (socket) => {
    console.log("🟢 Socket connected:", socket.id);

    socket.on("ask_question", async (payload) => {
      // payload: { userId, question }
      console.log("Question received:", payload);

      // مثال: إرسال رد مبدئي - استبدل لاحقًا بنداء لوحدة AI
      const answer = `تم استلام سؤالك: ${payload.question}`;
      io.emit("answer", { to: payload.userId, answer });
    });

    socket.on("join_room", (room) => {
      socket.join(room);
      socket.emit("joined", `Joined ${room}`);
    });

    socket.on("disconnect", () => {
      console.log("🔴 Socket disconnected:", socket.id);
    });
  });
};
