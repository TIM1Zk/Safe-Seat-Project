const supabase = require('./dbClient');

class BuddyRequestModel {
  // 1. ส่งคำขอ (leaderid = คนส่ง, followerid = คนรับ)
  static async sendRequest(senderId, receiverId) {
    const { data, error } = await supabase
      .from('buddyteam')
      .insert([
        { 
          leaderid: senderId, 
          followerid: receiverId, 
          teamstatus: 'pending',
          currentloclat: 0, // ใส่ค่าเริ่มต้นเนื่องจากเป็น NOT NULL
          currentloclng: 0 
        }
      ])
      .select()
      .maybeSingle();

    if (error) throw error;
    return data;
  }

  // 2. ดึงคำขอที่ส่งมาถึงเรา (followerid = เรา)
  static async getPendingRequests(userId) {
    // const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString();
    
    const { data, error } = await supabase
      .from('buddyteam')
      .select('*, sender:leaderid(username, firstname, lastname, regisimagepath)')
      .eq('followerid', userId)
      .eq('teamstatus', 'pending');
      // .gt('teamdate', fiveMinutesAgo);

    if (error) throw error;
    return data;
  }

  // 3. ยอมรับคำขอ (เปลี่ยน teamstatus เป็น Ready)
  static async acceptRequest(requestId) {
    const { data, error } = await supabase
      .from('buddyteam')
      .update({ teamstatus: 'Ready' })
      .eq('buddyteamid', requestId)
      .select();

    if (error) throw error;
    return data;
  }

  // 4. ปฏิเสธหรือลบคำขอ
  static async removeRequest(requestId) {
    const { error } = await supabase
      .from('buddyteam')
      .delete()
      .eq('buddyteamid', requestId);

    if (error) throw error;
    return { message: 'Deleted' };
  }

  // 5. ดูคู่หูปัจจุบัน
  static async getActiveBuddy(userId) {
    const { data, error } = await supabase
      .from('buddyteam')
      .select('*, leader:leaderid(username, firstname, lastname, regisimagepath), follower:followerid(username, firstname, lastname, regisimagepath)')
      .or(`leaderid.eq.${userId},followerid.eq.${userId}`)
      .eq('teamstatus', 'Ready')
      .maybeSingle();

    if (error) throw error;
    return data;
  }
}

module.exports = BuddyRequestModel;
