import {User} from "./user";

export interface Appointment {
  id?: number,
  date?: Date,
  patient?: User,
  doctor?: User,
}
