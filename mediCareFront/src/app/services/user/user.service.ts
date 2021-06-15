import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {map} from "rxjs/operators";
import {User} from "../../models/user";

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private REST_API_SERVER = "http://localhost:3000";

  constructor(private httpClient: HttpClient) {
  }

  loginUser(payload: User) {
    return this.httpClient.post(this.REST_API_SERVER + "/login", payload, {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Allow-Origin': '*'
      }
    }).pipe(map(res => {
      return res;
    }))
  }

  registerUser(payload: User) {
    return this.httpClient.post(this.REST_API_SERVER + "/register2", payload, {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Allow-Origin': '*'
      }
    }).pipe(map(res => {
      return res;
    }))
  }

  logoutUser(payload: User) {
    return this.httpClient.post(this.REST_API_SERVER + "/logout", payload, {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Allow-Origin': '*'
      }
    }).pipe(map(res => {
      return res;
    }))
  }
}
