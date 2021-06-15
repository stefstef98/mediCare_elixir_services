import {Injectable} from '@angular/core';
import {JwtHelperService} from "@auth0/angular-jwt";

@Injectable({
  providedIn: 'root'
})
export class StorageService {
  private jwtHelper: JwtHelperService;

  constructor() {
    this.jwtHelper = new JwtHelperService();
  }

  setDataInLocalStorage(variableName: string, data: string) {
    localStorage.setItem(variableName, data);
  }

  getJwtToken() {
    return localStorage.getItem('token');
  }

  getId() {
    return localStorage.getItem('id')
  }

  getUsername() {
    return localStorage.getItem('username')
  }

  clearStorage() {
    localStorage.clear();
  }

}
