import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {map} from "rxjs/operators";
import {User} from "../../models/user";

@Injectable({
  providedIn: 'root'
})
export class UserService {
  // TODO fix this
  private REST_API_SERVER = "http://localhost:3000/";

  constructor(private httpClient: HttpClient) {
  }

  loginUser(payload: User) {
    return this.httpClient.post(this.REST_API_SERVER + "/login", payload).pipe(map(res => {
      return res;
    }))
  }

  registerUser(payload: User) {
    return this.httpClient.post(this.REST_API_SERVER + "/register", payload).pipe(map(res => {
      return res;
    }))
  }
}
