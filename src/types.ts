
export interface ConsumptionRecord {
  timestamp: Date;
  userId: string;
  userName: string;
  beverageName: string;
  price: number;
}

export interface User {
    userId: string;
    userName:string;
}

export interface ApiCredentials {
  projectId: string;
  id: string;
  password: string;
}
